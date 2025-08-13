type severity = Warning | Error

type position = { 
  line: int; 
  column: int 
}

type lint_result = {
  file: string;
  severity: severity;
  rule: string;
  message: string;
  position: position;
}

type config = {
  exclude_patterns: string list;
  include_extensions: string list;
}

let path_separator = if Sys.os_type = "Win32" then "\\" else "/"

let combine_path dir entry = 
  if dir = "." then entry 
  else dir ^ path_separator ^ entry

let is_directory path =
  try Sys.is_directory path
  with Sys_error _ -> false

let read_directory dir =
  try
    let files = Array.to_list (Sys.readdir dir) in
    List.filter (fun f -> f <> "." && f <> "..") files
  with Sys_error _ -> []

let should_exclude_file file_path {exclude_patterns; _} =
  List.exists (fun pattern ->
    String.contains file_path (String.get pattern 0)
  ) exclude_patterns

let has_valid_extension file_path {include_extensions; _} =
  List.exists (fun ext ->
    let ext_len = String.length ext in
    let file_len = String.length file_path in
    file_len >= ext_len && String.sub file_path (file_len - ext_len) ext_len = ext
  ) include_extensions

let rec scan_directory dir config =
  let files = ref [] in
  let entries = read_directory dir in
  List.iter (fun entry ->
    let full_path = combine_path dir entry in
    if not (should_exclude_file full_path config) then
      if is_directory full_path then
        files := (scan_directory full_path config) @ !files
      else if has_valid_extension full_path config then
        files := full_path :: !files
  ) entries;
  !files

module Linter = struct
  let check_const_preference content filename =
    let open Str in
    let lines = String.split_on_char '\n' content in
    let results = ref [] in
    List.iteri (fun line_num line ->
      if string_match (regexp "\\blet\\b") line 0 &&
         not (string_match (regexp "\\blet\\s+\\w+\\s*:[^=]+=") line 0) &&
         not (string_match (regexp "\\blet\\s+\\w+\\s*=.*[+-]=") line 0) &&
         not (string_match (regexp "\\blet\\s+\\w+\\s*=.*[+-]{2}") line 0) &&
         not (string_match (regexp "\\blet\\s+\\w+\\s*=[^=]*=(?!=)") line 0) then
        results := {
          file = filename;
          severity = Error;
          rule = "prefer-const";
          message = "Use 'const' instead of 'let' when variable is not reassigned";
          position = { line = line_num + 1; column = match try Some (search_forward (regexp "let") line 0) with Not_found -> None with Some pos -> pos | None -> 0 };
        } :: !results
    ) lines;
    !results

  let check_semicolons content filename =
    let open Str in
    let lines = String.split_on_char '\n' content in
    let results = ref [] in
    List.iteri (fun line_num line ->
      let line = String.trim line in
      if line <> "" && 
         not (string_match (regexp "^\\s*$") line 0) &&
         not (string_match (regexp "^\\s*[{}]\\s*$") line 0) &&
         not (string_match (regexp ".*[;{}]\\s*$") line 0) &&
         not (string_match (regexp "^\\s*import\\s+.*from\\s+.*") line 0) &&
         not (string_match (regexp "^\\s*export\\s+.*") line 0) &&
         not (string_match (regexp "^\\s*//") line 0) &&
         not (string_match (regexp "^\\s*[a-zA-Z_][a-zA-Z0-9_]*:") line 0) then
        results := {
          file = filename;
          severity = Error;
          rule = "semicolons";
          message = "Missing semicolon at end of statement";
          position = { line = line_num + 1; column = String.length (String.trim line) };
        } :: !results
    ) lines;
    !results

  let check_template_literals content filename =
    let open Str in
    let lines = String.split_on_char '\n' content in
    let results = ref [] in
    List.iteri (fun line_num line ->
      let line = String.trim line in
      if string_match (regexp "\\+") line 0 ||
         string_match (regexp "['\"].*['\"]\\s*\\+") line 0 ||
         string_match (regexp "\\+\\s*['\"].*['\"]") line 0 then
        results := {
          file = filename;
          severity = Error;
          rule = "template-literals";
          message = "Use template literals instead of string concatenation";
          position = { line = line_num + 1; column = match try Some (search_forward (regexp "\\+") line 0) with Not_found -> None with Some pos -> pos | None -> 0 };
        } :: !results
    ) lines;
    !results

  let check_variable_naming content filename =
    let open Str in
    let lines = String.split_on_char '\n' content in
    let results = ref [] in
    List.iteri (fun line_num line ->
      if string_match (regexp "_") line 0 &&
         string_match (regexp "\\b(let|const|var)\\s+\\w*_\\w*\\b") line 0 then
        results := {
          file = filename;
          severity = Error;
          rule = "naming-convention";
          message = "Use camelCase for variable names instead of snake_case";
          position = { line = line_num + 1; column = match try Some (search_forward (regexp "_") line 0) with Not_found -> None with Some pos -> pos | None -> 0 };
        } :: !results
    ) lines;
    !results

  let check_no_var content filename =
    let open Str in
    let lines = String.split_on_char '\n' content in
    let results = ref [] in
    List.iteri (fun line_num line ->
      if string_match (regexp "\\bvar\\b") line 0 then
        results := {
          file = filename;
          severity = Error;
          rule = "no-var";
          message = "Use 'let' or 'const' instead of 'var'";
          position = { line = line_num + 1; column = match try Some (search_forward (regexp "var") line 0) with Not_found -> None with Some pos -> pos | None -> 0 };
        } :: !results
    ) lines;
    !results

  let lint_file content filename =
    let all_results = [
      check_const_preference;
      check_semicolons;
      check_template_literals;
      check_variable_naming;
      check_no_var;
    ] in
    List.flatten (List.map (fun check -> check content filename) all_results)

end


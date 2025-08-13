open Types

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
    check_no_var;
  ] in
  List.flatten (List.map (fun check -> check content filename) all_results)

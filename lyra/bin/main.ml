open Printf
open Lyra

let process_file file_path =
  let content = 
    let ic = open_in file_path in
    let n = in_channel_length ic in
    let s = really_input_string ic n in
    close_in ic;
    s
  in
  let results = Linter.lint_file content file_path in
  List.iter (fun result ->
    printf "%s:%d:%d: %s [%s] %s\n"
      result.file 
      result.position.line 
      result.position.column
      (match result.severity with Warning -> "WARNING" | Error -> "ERROR")
      result.rule
      result.message
  ) results;
  results

let process_args () =
  let files = ref [] in
  let specs = [] in
  let usage_msg = "Usage: lyra [options] <files...>" in
  let anon_fun filename = files := filename :: !files in
  Arg.parse specs anon_fun usage_msg;
  !files

let () =
  let files = process_args () in
  let file_count = ref 0 in
  let error_count = ref 0 in
  let warning_count = ref 0 in
  
  List.iter (fun file ->
    incr file_count;
    let results = process_file file in
    List.iter (fun result ->
      match result.severity with
      | Error -> incr error_count
      | Warning -> incr warning_count
    ) results
  ) files;
  
  printf "\n=== Lyra TypeScript Linter Summary ===\n";
  printf "Files scanned: %d\n" !file_count;
  printf "Errors: %d\n" !error_count;
  printf "Warnings: %d\n" !warning_count;
  printf "Total issues: %d\n" (!error_count + !warning_count);
  if !error_count > 0 then exit 1


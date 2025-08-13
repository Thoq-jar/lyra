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

val path_separator : string
val combine_path : string -> string -> string
val is_directory : string -> bool
val read_directory : string -> string list
val should_exclude_file : string -> config -> bool
val has_valid_extension : string -> config -> bool
val scan_directory : string -> config -> string list

module Linter : sig
  val check_const_preference : string -> string -> lint_result list
  val check_semicolons : string -> string -> lint_result list
  val check_template_literals : string -> string -> lint_result list
  val check_variable_naming : string -> string -> lint_result list
  val lint_file : string -> string -> lint_result list
end

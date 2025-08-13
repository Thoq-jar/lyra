open Types

val check_const_preference : string -> string -> lint_result list
val check_semicolons : string -> string -> lint_result list
val check_template_literals : string -> string -> lint_result list
val check_no_var : string -> string -> lint_result list
val lint_file : string -> string -> lint_result list

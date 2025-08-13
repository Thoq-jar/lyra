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

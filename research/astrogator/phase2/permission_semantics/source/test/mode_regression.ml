let expect label actual expected =
  if actual <> expected then failwith label else Printf.printf "PASS %s\n" label
let () =
  let norm=Modules.Permission_mode.normalize in
  expect "quoted octal" (norm "0700") (Some "0700");
  expect "complete symbolic" (norm "u=rwx,g=,o=") (Some "0700");
  expect "reordered complete classes" (norm "o=,u=rwx,g=") (Some "0700");
  expect "special bits" (norm "u=rws,g=rs,o=t") (Some "7640");
  expect "directory conditional X" (norm ~directory:true "u=rwX,g=,o=") (Some "0700");
  expect "unknown kind X declined" (norm "u=rwX,g=,o=") None;
  expect "partial chmod declined" (norm "u=rwx") None;
  expect "relative chmod declined" (norm "u+rwx,g=,o=") None;
  expect "permission copying declined" (norm "u=g,g=,o=") None;
  expect "duplicate classes declined" (norm "u=rwx,u=,o=") None;
  expect "invalid octal declined" (norm "0888") None;
  expect "float spelling declined" (norm "700.0") None;
  expect "dynamic mode declined" (norm "{{ mode }}") None;
  expect "no permission integration by default" !Modules.Permission_mode.enabled false

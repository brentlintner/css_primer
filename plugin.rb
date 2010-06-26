# redcar plugin manifest
Plugin.define do
  name    "css_primer"
  version "0.1"
  file    "lib", "css_primer_plugin"
  object  "Redcar::CSSPrimerPlugin"
  dependencies "redcar", ">0"
end
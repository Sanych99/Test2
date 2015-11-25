FILE(REMOVE_RECURSE
  "reflect_msg.beam"
  "chat_server.beam"
  "link_tester.beam"
  "CMakeFiles/link_tester"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/link_tester.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)

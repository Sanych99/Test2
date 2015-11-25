FILE(REMOVE_RECURSE
  "reflect_msg.beam"
  "chat_server.beam"
  "link_tester.beam"
  "CMakeFiles/build_erlang"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/build_erlang.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)

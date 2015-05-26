-module(ibot_ui_interaction_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Static = fun(Filetype) ->
        {lists:append(["/", Filetype, "/[...]"]), cowboy_static, [
            {directory, {priv_dir, ibot_webi, [list_to_binary(Filetype)]}},
            {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
        ]}
    end,
    Dispatch = cowboy_router:compile([
        {'_', [
            Static("css"),
            Static("js"),
            Static("img"),
            {"/cssStyle", cowboy_static, {priv_file, ibot_webi, "css/style.css"}},
            {"/jsJquery", cowboy_static, {priv_file, ibot_webi, "js/jquery.min.js"}},
            %{"/", cowboy_static, {priv_file, ibot_webi, "index.html"}},
            %{"/pageConnectToProject", cowboy_static, {priv_file, ibot_webi, "pageConnectToProject.html"}},
            %{"/pageCreateProject", cowboy_static, {priv_file, ibot_webi, "pageCreateProject.html"}},
            %{"/pageCreateNode", cowboy_static, {priv_file, ibot_webi, "pageCreateNode.html"}},
            %{"/pageNodeList", cowboy_static, {priv_file, ibot_webi, "pageNodeList.html"}},
            {"/websocket", ibot_webi_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 5959}],
        [{env, [{dispatch, Dispatch}]}]),
    ibot_ui_interaction_sup:start_link().

stop(_State) ->
    ok.

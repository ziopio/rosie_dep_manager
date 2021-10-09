-module(ros2_official_resource).
-behaviour(rebar_resource ).
-export([init/2,
         lock/2,
         download/4, download/3,
         needs_update/2,
         make_vsn/1]).



-include_lib("kernel/include/file.hrl").

%% Initialize the custom dep resource plugin
init(Type, _RebarState) ->
   CustomState = #{},
   Resource = rebar_resource_v2:new(
       Type,         % type tag such as 'git' or 'hg'
       ?MODULE,      % this callback module
       CustomState   % anything you want to carry around for next calls
   ),
   {ok, Resource}.

lock(AppInfo, CustomState) ->
  %% Extract info such as {Type, ResourcePath, ...} as declared
  %% in rebar.config
  SourceTuple = rebar_git_resource:lock(AppInfo, CustomState),
  %% Annotate and modify the source tuple to make it absolutely
  %% and indeniably unambiguous (for example, with git this means
  %% transforming a branch name into an immutable ref)

  %% Return the unambiguous source tuple
  ModifiedSource= SourceTuple.

download(TmpDir, AppInfo, CustomState) ->
        %% Extract info such as {Type, ResourcePath, ...} as declared
        %% in rebar.config
        rebar_git_resource:download(TmpDir, AppInfo, CustomState),
        %% Download the resource defined by SourceTuple, which should be
        %% an OTP application or library, into TmpDir
        ok.
  
download(TmpDir, AppInfo, CustomState, RebarState) ->
        download(TmpDir, AppInfo, CustomState),
        ok.
make_vsn(Dir) ->
  %% Extract a version number from the application. This is useful
  %% when defining the version in the .app.src file as `{version, Type}',
  %% which means it should be derived from the build information. For
  %% the `git' resource, this means looking for the last tag and adding
  %% commit-specific information
  rebar_git_resource:make_vsn(Dir).
  

needs_update(AppInfo, ResourceState) ->
  %% Extract the Source tuple if needed
  SourceTuple = rebar_app_info:source(AppInfo),
  %% Base version in the current file
  OriginalVsn = rebar_app_info:original_vsn(AppInfo),
  %% Check if the copy in the current install matches
  %% the defined value in the source tuple. On a conflict,
  %% return `true', otherwise `false'
  rebar_git_resource:needs_update(AppInfo, ResourceState).
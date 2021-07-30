%%%===================================================================
%%% Copyright (c) 2011, Klas Johansson
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are
%%% met:
%%%
%%%     * Redistributions of source code must retain the above copyright
%%%       notice, this list of conditions and the following disclaimer.
%%%
%%%     * Redistributions in binary form must reproduce the above copyright
%%%       notice, this list of conditions and the following disclaimer in
%%%       the documentation and/or other materials provided with the
%%%       distribution.
%%%
%%%     * Neither the name of the copyright holder nor the names of its
%%%       contributors may be used to endorse or promote products derived
%%%       from this software without specific prior written permission.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
%%% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
%%% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
%%% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
%%% HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
%%% TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
%%% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%%% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%%% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%%% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%===================================================================

%%%-------------------------------------------------------------------
%%% @doc
%%% Eunit addons make it easier to work with tests that require
%%% some kind of setup/cleanup to be performed before/after each test.
%%%
%%% Include the following in your eunit test suite and you should be
%%% on your way.  You don't have to include the
%%% eunit/include/eunit.hrl, since that's automatically included
%%% by the line below:
%%% ```
%%%     -include_lib("eunit_addons/include/eunit_addons.hrl").
%%% '''
%%%
%%% This adds a set of macros which help you write eunit tests.
%%%
%%% == Run all ..._test/1 functions with setup/cleanup ==
%%% Benefits of these macros:
%%% <ul>
%%%     <li>They make it easier to work with setup/cleanup
%%%         before/after eunit tests (like eunit fixtures, but easier).</li>
%%%     <li>They provide readable test names (same as the function
%%%         name) to the eunit printout.</li>
%%%     <li>They make it easy to set timeouts for test cases.</li>
%%%     <li>The tests get isolated from each other.</li>
%%% </ul>
%%%
%%% NOTE: Use one of the ?WITH_SETUP macros with fewer parameters (if
%%%       possible), since these don't require that the list of tests
%%%       to be run are be specified but rather deduce that from the
%%%       test module itself.  However, the version of the macro which
%%%       has the `Tests' parameter might be useful when there are
%%%       different groups of tests in one module which require
%%%       different setup.
%%%
%%% The `{spawn,Test}' feature of eunit is used to achieve test isoloation.
%%%
%%% === Run all ..._test/1 functions (with default timeouts) ===
%%% This:
%%% ```
%%%     ?WITH_SETUP(SetupFun, CleanupFun)
%%% '''
%%% is equivalent to:
%%% ```
%%%     ?WITH_SETUP(SetupFun, CleanupFun, 120, 30)
%%% '''
%%% See ?WITH_SETUP/4 for details.
%%%
%%% Example: Run all functions named `..._test/1' in the current module
%%% with default timeouts.  Start a server as part of the setup.
%%% The `..._test_/0' function is a test generator (this is how eunit
%%% works; it must be named `..._test_/0').  The ?WITH_SETUP macro will
%%% only look for functions named `..._test/1' and run these.
%%% ```
%%%     my_server_test_() ->
%%%         ?WITH_SETUP(fun() ->
%%%                         {ok, Pid} = my_server:start_link(),
%%%                         Pid
%%%                     end,
%%%                     fun(Pid) ->
%%%                         my_server:stop(Pid)
%%%                     end).
%%%
%%%     returns_foo_test(Pid) ->
%%%         foo = my_server:get_foo(Pid).
%%%
%%%     returns_bar_test(Pid) ->
%%%         bar = my_server:get_bar(Pid).
%%% '''
%%% In the above example, functions are called in this order:
%%% ```
%%%     setup fun() -> Pid1
%%%     returns_foo_test(Pid1)
%%%     cleanup fun(Pid1)
%%%
%%%     setup fun() -> Pid2
%%%     returns_bar_test(Pid2)
%%%     cleanup fun(Pid2)
%%% '''
%%%
%%% === Run all ..._test/1 functions (with user-defined timeouts) ===
%%% This:
%%% ```
%%%     ?WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout)
%%% '''
%%% is equivalent to:
%%% ```
%%%     ?WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout,
%%%                 ListOfAllTestFunctionsInModuleWithArityOne)
%%% '''
%%% See ?WITH_SETUP/5 for details.
%%%
%%% Example: Run all functions named `..._test/1' in the current module
%%% with user-defined timeouts.  Start a server as part of the setup.
%%% The `..._test_/0' function is a test generator (this is how eunit
%%% works; it must be named `..._test_/0').  This ?WITH_SETUP macro will
%%% run all tests in `Tests'.
%%% ```
%%%     my_server_test_() ->
%%%         ?WITH_SETUP(fun() ->
%%%                         {ok, Pid} = my_server:start_link(),
%%%                         Pid
%%%                     end,
%%%                     fun(Pid) ->
%%%                         my_server:stop(Pid)
%%%                     end,
%%%                     120,  % timeout for all tests
%%%                     60).  % timeout for each test
%%%
%%%     returns_foo_test(Pid) ->
%%%         foo = my_server:get_foo(Pid).
%%%
%%%     returns_bar_test(Pid) ->
%%%         bar = my_server:get_bar(Pid).
%%% '''
%%% In the above example, functions are called in this order:
%%% ```
%%%     setup fun() -> Pid1
%%%     returns_foo_test(Pid1)
%%%     cleanup fun(Pid1)
%%%
%%%     setup fun() -> Pid2
%%%     returns_bar_test(Pid2)
%%%     cleanup fun(Pid2)
%%% '''
%%%
%%% === Run a subset of test functions (with user-defined timeouts) ===
%%% ```
%%%     ?WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout, Tests)
%%%         SetupFun = () -> State
%%%         CleanupFun = (State) -> void()
%%%         State = term()
%%%         ForAllTimeout = integer()
%%%         PerTcTimeout = integer()
%%%         Tests = [Test]
%%%         Test = atom()
%%% '''
%%%
%%% Runs `SetupFun' before and `CleanupFun' after each `Test'.
%%% `SetupFun' is a zero-argument fun which may do any setup that has
%%% to be done before the test is performed.  The result of this fun,
%%% `State', is passed to each of the `Tests' as well as the
%%% `CleanupFun'.  The `CleanupFun' is supposed to take care of any
%%% cleanup after the test and is called regardless of whether the
%%% test was successful or not.  Each `Test' must be a function of
%%% arity 1 (the parameter is the output from the `SetupFun').
%%%
%%% `ForAllTimeout' is the maximum time (in seconds) all the `Tests'
%%% are allowed to take.  `PerTcTimeout' is the maximum time (in
%%% seconds) a single `Test' is allowed to take.
%%%
%%% `Tests' is a list of names of functions (arity 1).  Each of these
%%% `Test' functions will be passed the output from the `SetupFun'.
%%%
%%% Example: Run a selected number of tests using user-defined timeouts:
%%% ```
%%%     my_server_foo_test_() ->
%%%         ?WITH_SETUP(fun setup_before_foo/0,
%%%                     fun cleanup_after_foo/1,
%%%                     120,  % timeout for all tests
%%%                     60,   % timeout for each test
%%%                     [returns_foo_test,   % run only `foo' tests
%%%                      sets_foo_test]).
%%%
%%%     returns_foo_test(Pid) ->
%%%         foo = my_server:get_foo(Pid).
%%%
%%%     sets_foo_test(Pid) ->
%%%         my_server:set_foo(Pid, foo2).
%%%         foo2 = my_server:get_foo(Pid).
%%%
%%%     my_server_bar_test_() ->
%%%         ?WITH_SETUP(fun setup_before_bar/0,
%%%                     fun cleanup_after_bar/1,
%%%                     120,  % timeout for all tests
%%%                     60,   % timeout for each test
%%%                     [returns_bar_test]). % run only `bar' tests
%%%
%%%     returns_bar_test(Pid) ->
%%%         bar = my_server:get_bar(Pid).
%%% '''
%%% In the above example, functions are called in this order:
%%% ```
%%%     %% foo tests
%%%     setup_before_foo() -> Pid1
%%%     returns_foo_test(Pid1)
%%%     cleanup_after_foo(Pid1)
%%%
%%%     setup_before_foo() -> Pid2
%%%     sets_foo_test(Pid2)
%%%     cleanup_after_foo(Pid2)
%%%
%%%     %% bar tests
%%%     setup_before_foo() -> Pid3
%%%     returns_bar_test(Pid3)
%%%     cleanup_after_bar(Pid3)
%%% '''
%%% @end
%%%-------------------------------------------------------------------
-module(eunit_addons).


%%--------------------------------------------------------------------
%% API
%%--------------------------------------------------------------------
-export([get_tests_with_setup/1]).

-export([parse_transform/2]).

%%--------------------------------------------------------------------
%% Internal exports
%%--------------------------------------------------------------------
-export([]).

%%--------------------------------------------------------------------
%% Include files
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% Definitions
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% Records
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% @doc Return a list of tests which require a setup (..._test/1).
%% @end
%%--------------------------------------------------------------------
-spec get_tests_with_setup(module()) -> [Fn :: atom()].
get_tests_with_setup(Module) ->
   [Fn || {Fn, Arity} <- Module:module_info(exports),
          is_test_with_setup_fn({Fn, Arity})].


%%--------------------------------------------------------------------
%% @private
%% @doc Run the parse transform.
%% @end
%%--------------------------------------------------------------------
-spec parse_transform(Forms0, Options) -> Forms when
      Forms0 :: [erl_syntax:syntaxTree()],
      Options :: [compile:option()],
      Forms :: [erl_syntax:syntaxTree()].
parse_transform(Forms0, _Options) ->
   ExportAttr = mk_export_attr(get_functions_to_export(Forms0)),
   Forms = insert_after_module_attr(Forms0, ExportAttr),
   erl_syntax:revert_forms(Forms).

%%--------------------------------------------------------------------
%% Internal functions
%%--------------------------------------------------------------------

is_test_with_setup_fn({Fn, Arity}) ->
   lists:suffix("_test", atom_to_list(Fn)) andalso Arity =:= 1.

get_functions_to_export(Forms) ->
   lists:foldl(
     fun(Form, Exports) ->
             case erl_syntax_lib:analyze_form(Form) of
                 {function, Function} ->
                     case is_test_with_setup_fn(Function) of
                         true  -> [Function | Exports];
                         false -> Exports
                     end;
                 _Other ->
                     Exports
             end
     end,
     [],
     Forms).

mk_export_attr(Exports) ->
   %% FIXME: Would be nice to use erl_syntax:attribute here, but I
   %%        could not get erl_syntax:revert to accept it (error in
   %%        parse transform ...)
   {attribute, 0, export, Exports}.

insert_after_module_attr([Form | Forms], ToAddForm) ->
   case erl_syntax_lib:analyze_form(Form) of
       {attribute, {module, _}} ->
           [Form, ToAddForm | Forms];
       _Other ->
           [Form | insert_after_module_attr(Forms, ToAddForm)]
   end;
insert_after_module_attr([], ToAddForm) ->
   ToAddForm.  %% in case there is no module attribute

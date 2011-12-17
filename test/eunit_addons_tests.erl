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
%%% Test {@link eunit_addons}
%%% @end
%%%-------------------------------------------------------------------
-module(eunit_addons_tests).

%%--------------------------------------------------------------------
%% Include files
%%--------------------------------------------------------------------
-include_lib("eunit_addons/include/eunit_addons.hrl").

with_fun_test_() ->
    ?WITH_FUN(fun(Test) -> apply(?MODULE, Test, [foo]) end).

with_setup_test_() ->
    ?WITH_SETUP(fun setup/0, fun cleanup/1).

setup() ->
    foo.

cleanup(foo) ->
    ok.

with_setup_1_test(foo) ->
    ok.

with_setup_2_test(foo) ->
    ok.

test_case_isolation_1_test(_) ->
    put(a, dummy).

test_case_isolation_2_test(_) ->
    undefined = get(a).

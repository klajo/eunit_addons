-ifndef(EUNIT_ADDONS_HRL).
-define(EUNIT_ADDONS_HRL, true).

-include_lib("eunit/include/eunit.hrl").
-include_lib("eunit_addons/include/eunit_addons.hrl").

-compile({parse_transform, eunit_addons}).

-ifndef(FOR_ALL_TIMEOUT).
-define(FOR_ALL_TIMEOUT, 120).
-endif. % FOR_ALL_TIMEOUT

-ifndef(PER_TC_TIMEOUT).
-define(PER_TC_TIMEOUT, 30).
-endif. % PER_TC_TIMEOUT

%% run a generic fun
-define(WITH_FUN(Fun, ForAllTimeout, PerTcTimeout, Tests),
        {timeout, ForAllTimeout,           %% timeout for all tests
         [{timeout, PerTcTimeout,          %% timeout for each test
           [{atom_to_list(__Test),         %% label per test
             {spawn, fun() -> Fun(__Test) end}}]}
          || __Test <- Tests]}).

-define(WITH_FUN(Fun, ForAllTimeout, PerTcTimeout),
        ?WITH_FUN(Fun, ForAllTimeout, PerTcTimeout,
                  eunit_addons:get_tests_with_setup(?MODULE))).

-define(WITH_FUN(Fun),
        ?WITH_FUN(Fun, ?FOR_ALL_TIMEOUT, ?PER_TC_TIMEOUT)).

%% normal setup
-define(WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout, Tests),
        {timeout, ForAllTimeout,           %% timeout for all tests
         [{timeout, PerTcTimeout,          %% timeout for each test
           [{atom_to_list(__Test),         %% label per test
             {spawn, fun() ->
                             Env = SetupFun(),
                             try
                                 apply(?MODULE, __Test, [Env])
                             after
                                 CleanupFun(Env)
                             end
                     end}}]}
          || __Test <- Tests]}).

-define(WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout),
        ?WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout,
                    eunit_addons:get_tests_with_setup(?MODULE))).

-define(WITH_SETUP(SetupFun, CleanupFun),
        ?WITH_SETUP(SetupFun, CleanupFun, ?FOR_ALL_TIMEOUT, ?PER_TC_TIMEOUT)).

-endif. % EUNIT_ADDONS_HRL

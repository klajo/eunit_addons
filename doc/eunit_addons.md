

#Module eunit_addons#
* [Description](#description)
* [Function Index](#index)
* [Function Details](#functions)


   
Eunit addons make it easier to work with tests that require   
some kind of setup/cleanup to be performed before/after each test.

<a name="description"></a>

##Description##


Include the following in your eunit test suite and you should be
on your way.  You don't have to include the
eunit/include/eunit.hrl, since that's automatically included
by the line below:
<pre>       -include_lib("eunit_addons/include/eunit_addons.hrl").</pre>



This adds a set of macros which help you write eunit tests.



###<a name="Run_all_..._test/1_functions_with_setup/cleanup">Run all ..._test/1 functions with setup/cleanup</a>##

Benefits of these macros:

* They make it easier to work with setup/cleanup
before/after eunit tests (like eunit fixtures, but easier).

* They provide readable test names (same as the function
name) to the eunit printout.

* They make it easy to set timeouts for test cases.

* The tests get isolated from each other.





NOTE: Use one of the ?WITH_SETUP macros with fewer parameters (if
possible), since these don't require that the list of tests
to be run are be specified but rather deduce that from the
test module itself.  However, the version of the macro which
has the `Tests` parameter might be useful when there are         
different groups of tests in one module which require         
different setup.



The `{spawn,Test}` feature of eunit is used to achieve test isoloation.



####<a name="Run_all_..._test/1_functions_(with_default_timeouts)">Run all ..._test/1 functions (with default timeouts)</a>##

This:
<pre>       ?WITH_SETUP(SetupFun, CleanupFun)</pre>
is equivalent to:
<pre>       ?WITH_SETUP(SetupFun, CleanupFun, 120, 30)</pre>

   
See ?WITH_SETUP/4 for details.

Example: Run all functions named `..._test/1` in the current module
with default timeouts.  Start a server as part of the setup.
The `..._test_/0` function is a test generator (this is how eunit
works; it must be named `..._test_/0`).  The ?WITH_SETUP macro will
only look for functions named `..._test/1` and run these.
<pre>       my_server_test_() ->
           ?WITH_SETUP(fun() ->
                           {ok, Pid} = my_server:start_link(),
                           Pid
                       end,
                       fun(Pid) ->
                           my_server:stop(Pid)
                       end).
  
       returns_foo_test(Pid) ->
           foo = my_server:get_foo(Pid).
  
       returns_bar_test(Pid) ->
           bar = my_server:get_bar(Pid).</pre>
In the above example, functions are called in this order:
<pre>       setup fun() -> Pid1
       returns_foo_test(Pid1)
       cleanup fun(Pid1)
  
       setup fun() -> Pid2
       returns_bar_test(Pid2)
       cleanup fun(Pid2)</pre>



####<a name="Run_all_..._test/1_functions_(with_user-defined_timeouts)">Run all ..._test/1 functions (with user-defined timeouts)</a>##

This:
<pre>       ?WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout)</pre>
is equivalent to:
<pre>       ?WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout,
                   ListOfAllTestFunctionsInModuleWithArityOne)</pre>

   
See ?WITH_SETUP/5 for details.

Example: Run all functions named `..._test/1` in the current module
with user-defined timeouts.  Start a server as part of the setup.
The `..._test_/0` function is a test generator (this is how eunit
works; it must be named `..._test_/0`).  This ?WITH_SETUP macro will
run all tests in `Tests`.
<pre>       my_server_test_() ->
           ?WITH_SETUP(fun() ->
                           {ok, Pid} = my_server:start_link(),
                           Pid
                       end,
                       fun(Pid) ->
                           my_server:stop(Pid)
                       end,
                       120,  % timeout for all tests
                       60).  % timeout for each test
  
       returns_foo_test(Pid) ->
           foo = my_server:get_foo(Pid).
  
       returns_bar_test(Pid) ->
           bar = my_server:get_bar(Pid).</pre>
In the above example, functions are called in this order:
<pre>       setup fun() -> Pid1
       returns_foo_test(Pid1)
       cleanup fun(Pid1)
  
       setup fun() -> Pid2
       returns_bar_test(Pid2)
       cleanup fun(Pid2)</pre>



####<a name="Run_a_subset_of_test_functions_(with_user-defined_timeouts)">Run a subset of test functions (with user-defined timeouts)</a>##

<pre>       ?WITH_SETUP(SetupFun, CleanupFun, ForAllTimeout, PerTcTimeout, Tests)
           SetupFun = () -> State
           CleanupFun = (State) -> void()
           State = term()
           ForAllTimeout = integer()
           PerTcTimeout = integer()
           Tests = [Test]
           Test = atom()</pre>



Runs `SetupFun` before and `CleanupFun` after each `Test`.
`SetupFun` is a zero-argument fun which may do any setup that has
to be done before the test is performed.  The result of this fun,
`State`, is passed to each of the `Tests` as well as the
`CleanupFun`.  The `CleanupFun` is supposed to take care of any
cleanup after the test and is called regardless of whether the
test was successful or not.  Each `Test` must be a function of
arity 1 (the parameter is the output from the `SetupFun`).



`ForAllTimeout` is the maximum time (in seconds) all the `Tests`
are allowed to take.  `PerTcTimeout` is the maximum time (in
seconds) a single `Test` is allowed to take.



`Tests` is a list of names of functions (arity 1).  Each of these
`Test` functions will be passed the output from the `SetupFun`.

Example: Run a selected number of tests using user-defined timeouts:
<pre>       my_server_foo_test_() ->
           ?WITH_SETUP(fun setup_before_foo/0,
                       fun cleanup_after_foo/1,
                       120,  % timeout for all tests
                       60,   % timeout for each test
                       [returns_foo_test,   % run only `foo' tests
                        sets_foo_test]).
  
       returns_foo_test(Pid) ->
           foo = my_server:get_foo(Pid).
  
       sets_foo_test(Pid) ->
           my_server:set_foo(Pid, foo2).
           foo2 = my_server:get_foo(Pid).
  
       my_server_bar_test_() ->
           ?WITH_SETUP(fun setup_before_bar/0,
                       fun cleanup_after_bar/1,
                       120,  % timeout for all tests
                       60,   % timeout for each test
                       [returns_bar_test]). % run only `bar' tests
  
       returns_bar_test(Pid) ->
           bar = my_server:get_bar(Pid).</pre>
In the above example, functions are called in this order:
<pre>       %% foo tests
       setup_before_foo() -> Pid1
       returns_foo_test(Pid1)
       cleanup_after_foo(Pid1)
  
       setup_before_foo() -> Pid2
       sets_foo_test(Pid2)
       cleanup_after_foo(Pid2)
  
       %% bar tests
       setup_before_foo() -> Pid3
       returns_bar_test(Pid3)
       cleanup_after_bar(Pid3)</pre><a name="index"></a>

##Function Index##


<table width="100%" border="1" cellspacing="0" cellpadding="2" summary="function index"><tr><td valign="top"><a href="#get_tests_with_setup-1">get_tests_with_setup/1</a></td><td>Return a list of tests which require a setup (..._test/1).</td></tr></table>


<a name="functions"></a>

##Function Details##

<a name="get_tests_with_setup-1"></a>

###get_tests_with_setup/1##




<pre>get_tests_with_setup(Module) -&gt; [{Fn, Arity}]</pre>
<ul class="definitions"><li><pre>Fn = atom()</pre></li><li><pre>Arity = integer()</pre></li></ul>



Return a list of tests which require a setup (..._test/1).
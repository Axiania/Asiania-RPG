# Features

## Using Callbacks

"y_inline" doesn't actually have to accept `inline` functions:

```pawn
#include <YSI_Coding\y_inline>

public Response(playerid, dialogid, response, listitem, string:inputtext[])
{
	#pragma unused dialogid, inputtext
	
	if (response)
	{
		va_SendClientMessage(playerid, COLOUR_MSG, "You picked: %d", listitem);
	}
	else
	{
		SendClientMessage(playerid, COLOUR_MSG, "You pressed cancel");
	}
}

CMD:pick(playerid, params[])
{
	// Called when the player responds to the dialog.
	Dialog_ShowCallback(playerid, using public Response<iiiis>, DIALOG_STYLE_LIST, "Pick a number", "0\n1\n2\n3\n4", "OK", "Cancel");
	return 1;
}
```

The major difference is in the type safety.  Here `Dialog_ShowCallback` takes a function with 4 integer parameters and one string parameter.  If `Response` were an inline, the compiler could determine that the parameters were correct automatically.  However, since this is a public, we must tell the compiler that this is correct.  Hence the `<iiiis>` after the function name.

## Closures

When you are in an inline, the variables from the enclosing function are available:

```pawn
#include <YSI_Coding\y_inline>

CountFives(array[], size)
{
	new count = 0;
	inline IsFive(value)
	{
		if (value == 5)
			++count;
	}
	ForEach(array, using inline IsFive, size);
	return count;
}
```

Each time `IsFive` is called (once per array element), `count` has kept its value from the last call, so this will correctly increment.  When `ForEach` ends, the `count` value needs to be correctly written back to the calling function via `Callback_Restore()`:

```pawn
ForEach(array[], Func:callback<i>, size)
{
	for (new i = 0; i != size; ++i)
	{
		@.callback(array[i]);
	}
	Callback_Restore(callback);
}
```

## `const`

Modifying variables in closures, and keeping them updated for multiple calls, is a non-zero amount of code.  If you don't modify them ever, then you can skip the restoration with `inline const`:

```pawn
#include <YSI_Coding\y_inline>

CountFives(array[], size)
{
	new count = 0;
	inline const IsFive(value)
	{
		if (value == 5)
			++count;
	}
	ForEach(array, using inline IsFive, size);
	return count;
}
```

Even if `ForEach` is not modified, this will ALWAYS return `0` - because `count` is modified inside `IsFive`, but the new value is instantly forgotten when the current call ends.

## `Callback_Restore`

`Callback_Restore` copies the closure data back in to the original stack.  This is only useful when the inline isn't `const` (so there is modified data to copy) and the inline was instantly called (so the original stack still exists).  This is no use for callbacks or timers, because the original function ended before the inline was called, thus calling this will probably just corrupt random memory.

### Non-`const` with `Callback_Restore`:

```pawn
CallAndCopy(Func:x<>)
{
	for (new i = 0; i != 10; ++i)
	{
		@.x();
	}
	Callback_Restore(x);
}

Test()
{
	new a = 1;
	inline X()
	{
		printf("%d", a); // 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
		++a;
	}
	CallAndCopy(using inline X);
	printf("%d", a); // 11
}
```

Note that the value of `a` is modified and persisted, even after the calls to the inline have ended.

### Non-`const` without `Callback_Restore`:

```pawn
CallNoCopy(Func:x<>)
{
	for (new i = 0; i != 10; ++i)
	{
		@.x();
	}
}

Test()
{
	new a = 1;
	inline X()
	{
		printf("%d", a); // 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
		++a;
	}
	CallNoCopy(using inline X);
	printf("%d", a); // 1
}
```

In this case, the value of `a` still increments within the inline, because the lack of `const` keeps the current value within the internal data memory for this function.  However, because `Callback_Restore` is never called, it is never copied back to the main stack at the end.

### `const` with or without `Callback_Restore`:

```pawn
CallIrellevantCopy(Func:x<>)
{
	for (new i = 0; i != 10; ++i)
	{
		@.x();
	}
	Callback_Restore(x); // Irrelevant
}

Test()
{
	new a = 1;
	inline const X()
	{
		printf("%d", a); // 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
		++a;
	}
	CallIrellevantCopy(using inline X);
	printf("%d", a); // 11
}
```

With `const`, the closure is never persisted, so the value of `a` never updates between calls.  The presense of `Callback_Restore` in that code WILL copy the data back in to the stack, but this is just copying data over identical data.  However, the call-site of an inline will not always know that the declaration was `const`, so this is not entirely pointless (because the source may also NOT be `const`).

## Manipulation

Function handlers are just variables.  They can be stored, passed, and more:

```pawn
new Func:g_cb<>;

CalleeA(Func:cb<>)
{
	@.cb();
}

CalleeB()
{
	CalleeA(g_cb);
}

CalleeC(Func:cb<>)
{
	g_cb = cb;
	CalleeB();
}

Caller()
{
	inline Called()
	{
		print("hi");
	}
	CalleeC(using inline Called);
}
```

But don't forget closure rules - the data will be invalid after `CalleeC` ends (which in this example is after the other two callees end) unless you explicitly claim it.

## Type Safety

Lets write a `Fold` function - this takes a current array element and a running total, and does something to them.  So the function that gets called (`inline`, `public`, or other) needs two integer parameters - `current` and `accumulated`.  So we specify that `Fold` takes a function that takes two parameters using `Func:name<ii>`:

```pawn
Fold(array[], Func:callback<ii>, initial, size = sizeof (array))
{
	for (new i = 0; i != size; ++i)
	{
		initial = @.callback(array[i], initial);
	}
	Callback_Restore(callback);
	return initial;
}
```

The new `@.` syntax is used to call the function defined by `callback`.  `Fold` is called like so:

```pawn
#include <YSI_Coding\y_inline>

CountFives(array[], size = sizeof (array))
{
	inline const IsFive(value, count)
	{
		if (value == 5)
			return count + 1;
		return count;
	}
	return Fold(array, using inline IsFive, 0, size);
}
```

Here `IsFive` can safely be `const` because no closure variables are modified.

## `inline_return`

This is a work-around for a compiler limitation:

```pawn
#include <YSI_Coding\y_inline>

CountFives(array[], &total, size = sizeof (array))
{
	inline const IsFive(value, count)
	{
		if (value == 5)
			return count + 1;
		return count;
	}
	total = Fold(array, using inline IsFive, 0, size);
}
```

Here the `inline` function contains `return`, but the outer function doesn't.  Due to a known issue*, `inline` and outer functions must both return a number, or the `inline` function can return nothing.  If you want an `inline` function to return a number, but the outer function to return something else (say a string, or nothing), you need `inline_return` instead:

```pawn
#include <YSI_Coding\y_inline>

CountFives(array[], &total, size = sizeof (array))
{
	inline const IsFive(value, count)
	{
		if (value == 5)
			inline_return count + 1;
		inline_return count;
	}
	total = Fold(array, using inline IsFive, 0, size);
}
```

## Deferred Calls

Given the following code:

```pawn
#include <YSI_Coding\y_inline>

CountFives(array[], size)
{
	new count = 0;
	inline const IsFive(value)
	{
		if (value == 5)
			++count;
	}
	ForEach(array, using inline IsFive, size);
	return count;
}
```

`CountFives` is the *caller* function, `ForEach` is the *callee* function, and `IsFive` is *called* function.  `CountFives` calls `ForEach`, `ForEach` calls `IsFive` (possibly multiple times).  All the calls to `IsFive` must happen before `ForEach` ends (i.e. before `return count;` is run).  But what about timers and callbacks?  For example:

```pawn
forward InlineTimerCall(Func:tt<>);

public InlineTimerCall(Func:tt<>)
{
	@.tt();
}

SetInlineTimer(Func:tt<>, delay, bool:repeat)
{
	SetTimerEx("InlineTimerCall", delay, repeat, "i", _:tt);
}

PrintLater(a, b, c)
{
	inline const PrintNow()
	{
		printf("a = %d, b = %d, c = %d", a, b, c);
	}
	SetInlineTimer(using inline PrintNow, 1000, false);
}
```

Here `PrintLater` is the caller, `SetInlineTimer` is the callee, and `PrintNow` is the called.  However, it is NOT called before `SetInlineTimer` returns, because we defer the call via `SetTimerEx`.  Therefore we need some extra code to tell y_inline not to clear memory (i.e. get rid of the closure containing `a`, `b`, and `c`):

```pawn
forward InlineTimerCall(Func:tt<>, bool:repeat);

public InlineTimerCall(Func:tt<>, bool:repeat)
{
	@.tt();
	if (!repeat)
	{
		Indirect_Release(tt);
	}
}

SetInlineTimer(Func:tt<>, delay, bool:repeat)
{
	Indirect_Claim(tt);
	SetTimerEx("InlineTimerCall", delay, repeat, "ii", _:tt, _:repeat);
}
```

`PrintLater` doesn't need to change - all of this is transparent to the end-user of a library.  `Indirect_Claim` tells the memory to stay.  `Indirect_Release` tells it to go.

## Metadata

You can attach extra data to inline functions, for example, to write `KillInlineTimer`:

```pawn
SetInlineTimer(Func:tt<>, delay, bool:repeat)
{
	Indirect_Claim(tt);
	new timer = SetTimerEx("InlineTimerCall", delay, repeat, "ii", _:tt, _:repeat);
	Indirect_SetMeta(tt, timer);
	return _:tt;
}

KillInlineTimer(tt)
{
	new timer = Indirect_GetMeta(tt);
	KillTimer(timer);
	Indirect_Release(tt);
}
```

Here the true timer id is stored along-side the inline closure data, and the handle is disguised as a timer ID.

## `Indirect_FromCallback`

This is just a pre-defined public function:

```pawn
forward Indirect_FromCallback(Func:cb<>, bool:release);

public Indirect_FromCallback(Func:cb<>, bool:release)
{
	@.cb();
	if (release)
		Indirect_Release(cb);
}
```

You can use it any time you need to convert a public function to an inline (e.g. to wrap an existing API):

```pawn
stock BCrypt_HashInline(text[], cost, Func:cb<>)
{
	Indirect_Claim(cb);
	bcrypt_hash(text, cost, "Indirect_FromCallback", "ii", _:cb, true);
}
```

This is more common than you may think - closures mean that passing addition parameters to inline functions is rarely required.

## String Inputs

This doesn't work:

```pawn
PrintLater(string:str[])
{
	inline const PrintNow()
	{
		print(str);
	}
	SetInlineTimer(using inline PrintNow, 1000, false);
}
```

Any pointers parameters (references, strings, and arrays) to the caller function are not stored in the closure**.  The closure copies all the local memory automatically, this remote memory must be copied manually:

```pawn
PrintLater(string:str[])
{
	new localString[32];
	strcpy(localString, str);
	inline const PrintNow()
	{
		print(localString);
	}
	SetInlineTimer(using inline PrintNow, 1000, false);
}
```

## Backwards Compatibility

The old y_inline API - `Callback_Get`, `Callback_Call`, `E_CALLBACK_DATA` etc. still work, but will now give deprecation and tag mismatch warnings.  The former is for the functions - all but `Callback_Restore` have been replaced by *indirection.inc*, the latter is for passing inlines since the old version didn't check that the given functions had the correct types.  Also, because `Callback_Get` is no longer required, inlines can be used anywhere in the callee stack, not just the first called function.

## Destructors

Be very careful when using tags with destructors around inline functions.  Consider the following code:

```pawn
operator~(Tag:data[], len)
{
	// Destructor code goes here.
}

main()
{
	new Tag:a;
	
	inline Inline()
	{
	}
	DoCall(using inline Inline);
}
```

The destructor for `a` will be called when `main` ends, but won't be called when `Inline` ends, despite the fact that it is in scope via the closure.  On the other hand, an explict return will cause the destructor to be called:

```pawn
main()
{
	new Tag:a;
	
	inline Inline()
	{
		return; // Destructor called.
	}
	DoCall(using inline Inline);
}
```

Variables with destructors declared within the inline - either as parameters or locals, are always handled correctly.  It is only tagged destructors in the closure that are ambiguous (the correct behaviour isn't even obvious - should the destructor be called twice (or more, if the inline is called many times) on a single variable?)

# Examples

## Login Dialog

```pawn
#include <YSI_Coding\y_inline>

ShowLogin(MySQL:handle, playerid)
{
	// Called when the player responds to the dialog.
	inline const Login(pid, dialogid, response, listitem, string:inputtext[])
	{
		// `playerid` and `pid` are always the same - so we only really need
		// one of them (`pid` would be required if the inline was elsewhere).
		#pragma unused pid, dialogid, listitem
		
		// Did the user click cancel or not type anything?
		if (!response || isnull(inputtext))
		{
			// Try again.
			SendClientMessage(playerid, COLOUR_ERROR, "Login failed - please enter a password.");
			ShowLogin(handle, playerid);
			return;
		}
		
		// Called when the data is fully loaded from the database.
		inline const Loaded()
		{
			new
				count;
			if (!cache_get_row_count(count))
			{
				// There was an error loading the data.  Try again.
				SendClientMessage(playerid, COLOUR_ERROR, "Login failed - please try again.");
				ShowLogin(handle, playerid);
				return;
			}
			
			// Was the user found?
			if (count != 1)
			{
				// Try again.
				SendClientMessage(playerid, COLOUR_ERROR, "Login failed - unknown username or password.");
				ShowLogin(handle, playerid);
				return;
			}
			
			// Get the password hash and unique (user) ID.
			new
				uid,
				hash[BCRYPT_HASH_LENGTH];
			if (!cache_get_value_index(0, 0, hash) || !cache_get_value_index_int(0, 1, uid))
			{
				// There was an error loading the data.  Try again.
				SendClientMessage(playerid, COLOUR_ERROR, "Login failed - please try again.");
				ShowLogin(handle, playerid);
				return;
			}
			
			// Called when the comparison between the stored and entered
			// passwords is complete (so the login is complete).
			inline const Checked()
			{
				// Are the passwords the same?
				if (bcrypt_is_equal())
				{
					// The player logged in.  Tell everything else so they can
					// respond appropriately (start loading data etc.)
					CallRemoteFunction("OnPlayerLogin", "ii", playerid, uid);
				}
				else
				{
					// Typed the wrong password.  But never let the user know
					// the exact reason for the failure - saying `incorrect
					// password` tells them that the account exists, which may
					// be too much information.
					SendClientMessage(playerid, COLOUR_ERROR, "Login failed - unknown username or password.");
					
					// Try again.
					ShowLogin(handle, playerid);
				}
			}
			
			// Check that the DB hash is equal to `inputtext` after hashing.
			// `inputtext` is still in scope here thanks to "closures" -
			// anything defined in an outer function is available in an inner
			// inline.
			BCrypt_CheckInline(inputtext, hash, using inline Checked);
		}
		
		// Request data from the DB on this player.  Search by name.
		new name[MAX_PLAYER_NAME];
		GetPlayerName(playerid, name, sizeof (name));
		MySQL_PQueryInline(handle, using inline Loaded, "SELECT `password_hash`, `uid` FROM `users` WHERE `username` = '%e'", name);
	}
	
	// Show the login dialog box.  When it is responded to, the inline function
	// called `Login` is called.  Because inline functions follow scoping rules,
	// this must be defined BEFORE it is used (i.e. above).
	Dialog_ShowCallback(playerid, using inline Login, DIALOG_STYLE_PASSWORD, "Login", "Enter your password below", "OK", "Cancel");
}

public OnPlayerConnect(playerid)
{
	ShowLogin(gMySQL, playerid);
}
```

\* This is due to the way inlines are implemented with macros.  The compiler sees the outer function and any inline functions as one large function.  Thus, the compiler thinks that some parts of the large function has `return`s, while other parts don't.  This gives `warning 209: function "NAME" should return a value`.

\*\* More strictly, the parameter itself IS stored in the closure, but the memory it points to isn't.  There is no good way at run-time to determine pointer parameters, and so their destination memory isn't stored, thus the target could be no longer valid, or garbage.


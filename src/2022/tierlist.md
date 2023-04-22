# My Language Tierlist

#TABLE	.tierlist
USEFUL	Rust	Typescript	C#	C++
FUN	C	Lua	TCL
BEARABLE	Javascript	Go	Python
PAINFUL	Bash
TRASH	Perl
#END TABLE

## Notes
- `Rust` - Eh, You knew it was gonna be on the list. Rust is immensley complicated but It's not hard to be productive in it, But when I use it, I feel like I'm arguing with someone on how I should write my code..
It's good that the borrow checker has your back but you fight with it quite often, or at least until you develop an intuition for it. But it's not too bad once you get used to it.

- `C` is really fun to work in, Having full control of what is happening is a great way to feel all powerful. But it is really not a good choice for building anything very complicated.
And when it is used, there are often hacks or like annoying limitations that libraries have to work around which is all around quite frustrating. Not to say it's hard to use or anything just can get frustrating with time.
It's really quite a nice language and the new stuff in C23 should make it even better!, But Man it would be wonderful if it had lambdas... or a vector type... maybe I just want C++. It's easy to fumble in C when handling memory but once memory management clicks for you, It's not difficult

- `TCL` - This is a bit of qwirky one but it's quite interesting and there's a lot of stuff you can do in it, sort of like a cross between lua and lisp I'd wager. I find it more fun to work with then python and something surprising for an interpreted language, You have *gasp* true not fake threads.

- `Go` - The error handling is pretty painful but then so is C's.

- `C++` - C++ just fixes a lot of gripes I have with C, But it replaces C's foot pistol with a sniper rifle. Unless you're familiar with a debugger and the code you're running, It can be really hard to find errors in C++, It fixes a lot of the pain points in C and admittedly introduces it's own.
Just having namespaces, lambdas, struct methods you can actually use and lots of other additions make it really a lot less painful to use than C. I haven't used it in a really large project so I dont' know how it behaves in an enviroment like that.

- `Javascript` - This is the first language I learnt and I have a lot of love for it but not having types and constantly forced to fix your code because of some tiny thing you couldnt predict (cause again, no types la la la) can get really frustrating,
And even the ecosystem around it is just how to say *laden*. Even for simple things, The alternative to just DIY is something really complicated so you DIY and then your solution becomes complicated too and the cycle continues...

- `C#` - I tried it a little, and it was pleasant 🤷, Not really much to say, It's quite useful and these days it's multiplatform too, It neatly side steps the painful java buildsystem and hello world can be written in one line, How amazing is that??

- `Typescript` - I haven't explored every corner of Typescript's type system but it's still a great improvement to Javascript and the much better Editor integration it allows for is great.

- `Lua` - Lua is a lot like C but the stdlib is much smaller and has just what you really use (I mean when have you used strfry) and you never touch memory yourself.
It also combines hashmaps and vectors into one table, Which I honestly don't hate, I kind of wish other languages had this combo type, It can be really useful in some situations to have that extra array part.
It's quite delightful to work in Lua, You can learn it in one day and be off to the races. It's great for embedding for scripting / configuration, Eg: Neovim
1-Array indexing isn't hard to get used to, It's just a bit like you ask why.

- `Perl` - The syntax just confuses me a lot, Its like bash but even more messy somehow, But it is more powerful than bash that much is for sure, You can even use GTK from within Perl.. I really wouldnt suggest it though. Warnings and Errors arent amazing and types arent strict, More javascript like fun.

👋 Hello! This is the repo for my [site](https://undefineddarkness.github.io/) and
some of the tools used to make it.

Ngl, I mostly make the site as a fun programming challenge so there isnt much of a actual content

## Pond & Toad
Both toad and pond are written in bash and should be fairly simple to modify.

<details>
<summary>Reasoning</summary>

Because I like it this way, and I learnt something making them (mostly how to make bad regex but minor details >:) )
Most SSG's I have tried (tho I havent tried many) - make me feel limited and I cant figure out a way to do it withuot breaking the 
SSG's structure - they also have a super complicated themeing setup and generally force you to do things *their* way.
I like to think toad doesnt do this since it is just one plaintext file and everything can be modified to fit your needs perfectly

Pond I made because I was unhappy with how markdown handles newlines and wanted some more customization over how my format generated html.
Its really simple to extend and its entire syntax can be changed by modifying 2 files: `pond.sh` & `backend-web.sh`
I plan to allow pond to generate Manpages at some point but that is in the far future.

</details>

### 🐸 Toad
Toad is the SSG in charge of converting the *format* files to HTML using whatever format
command you wish (will simply copy any html files it finds), it also takes care of hot reloading, serving files and generating a index
It also supports a HTML format file for styling and such

Toad will substitute `!TITLE!` in the template file with the path to the article
and `!CONTENT!` with the generated content

### 🏞️ Pond
This is the default formatter to come with Toad and the one I have here, Its format isn't too hard and is as follows:
```

#PRESERVE-CENTER
Centers the content in a way as to preserve indentation (useful for ascii art)
#END PRESERVE-CENTER

RIGHT-ALIGN, CENTER also exist

#SH-SCRIPT
echo I will be executed and then my output will be substituted here!
#END SH-SCRIPT

#BOX
I will get a nice box around me
#END BOX

Each item in every row and for the column names MUST be seperated by a tab and any amount of spaces
#TABLE Col1	Col2	Col3
V1	V2	V3
#END TABLE

Any html in the source will be preserved, HTML is meant to be used freely for anything the formatter cannot achieve
```

## 🍱 Bento
Bento is a lil live server I cooked up that works in Deno 🦕,
After being dissatisfied with what existed currently,
It can listen to the file system and or update from a unix signal,
Its functions are very simple:
- Serve Static Files (uses `file` to guess mimetype)
- Generate a file tree
- Append a js script to any .html files 
- Establish a web socket connection
- Send a update signal when appropriate
- Be reasonably performant

## TODO:
- [x] Get rid of `reeplace`
- [ ] Make pond faster
- [ ] Documentation for bento

 Books API
===========

The books mod adds various different books and bookshelves to the game.
A bookshelf can only contain one type of book. If you take out a book from
the shelf, it will be re-populated after a while.


To auto-convert white bookshelves (`books:bookshelf_white`), create
the JSON file described below.


Example of `worldpath/libraries.json`:
```
{
	"group1": {
		"libraries": [
			{"minp": {"x": 20, "y": 9, "z": 2}, "maxp": {"x": 20, "y": 12, "z": 8}}
		],
		"types": [
			{ "data_formats": 0.4, "hf_freq": 0.3, "hf_freq2": 0.2, "program_c": 0.1 }
		]
	}
}
```
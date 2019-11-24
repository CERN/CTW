local S = minetest.get_translator("ctw_technologies")

--[[
The technologies are ordered by the timeline.
They have a "kind" field to indicate what kind of technology it is:
	hardware
	protocol
	service (web)
	software
]]


-- "It's the viking age" (= Internet Stone Age)
-- "Oh, that explains the laser raptors." (no worries, they're tamed)

-- <year number> = <year name>
-- The "year number" is the column in the technology tree
-- "" means span previous column here
ctw_technologies.year_captions = {}
-- Table is filled in in definitions list below

--{ s=<from year number>, e=<to year number>, n=<name>},
ctw_technologies.eras = {
	{ s=2, e=5, n=S("Internet Stone Age")},
	{ s=6, e=7, n=S("The Early Days of Hypertext")},
	{ s=8, e=10, n=S("HTML and HTTP")},
	{ s=11, e=12, n=S("The Earliest Browsers")},
	{ s=13, e=15, n=S("Standardisation and Liberation")},
}

local tlev

-- ===========
-- Before 1980
-- ===========
tlev = 1
ctw_technologies.year_captions[tlev] = "Before 1980"

-- protocol
ctw_technologies.register_technology("crc", {
	name = S("Cyclic Redundancy Check"),
	description = S("Automatic error correction to get valid data."),
	year = 1975,
	kind = "protocol",
	tree_level = tlev,
	tree_line = 1,
})

-- hardware
ctw_technologies.register_technology("fiber", {
	name = S("Optical Fiber"),
	description = S("Data transfer over light. Fast but experimental and expensive."),
	year = 1960,
	kind = "hardware",
	tree_level = tlev,
	tree_line = 3,
})

-- protocol
ctw_technologies.register_technology("ipnet", {
	name = S("IP Networking"),
	description = S("Addresses for your network computers"),
	year = 1978,
	kind = "protocol",
	tree_level = tlev,
	tree_line = 5,
})

-- software
ctw_technologies.register_technology("unix", {
	name = S("UNIX v4"),
	description = S("An OS to work fast and efficiently."),
	year = 1973,
	kind = "software",
	tree_level = tlev,
	tree_line = 7,
})

-- protocol
ctw_technologies.register_technology("ascii", {
	name = S("ASCII"),
	description = S("Standard for character encoding"),
	year = 1966,
	kind = "protocol",
	tree_level = tlev,
	tree_line = 9,
})

-- ===========
-- 1980 - 1983
-- ===========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1980 - 1982"

-- hardware
ctw_technologies.register_technology("e10base2", {
	name = S("E10BASE2 / thin Ethernet"),
	description = S("Coaxial ethernet cables to build up a network."),
	year = 1980,
	requires = {
		"crc"
	},
	conn_info = {
		crc = {start_shift=1,end_shift=0},
	},
	benefits = {
		{ type = "supply", item="reseau:copper_%t_wire 99", time_min=60, time_max=120 },
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 2,
})

-- protocol
ctw_technologies.register_technology("tcpip", {
	name = S("TCP/IP v4"),
	description = S("A reliable protocol to transmit data over a computer network."),
	year = 1981,
	requires = {
		"ipnet"
	},
	conn_info = {
		ipnet = {start_shift=2}
	},
	benefits = {
		{ type = "wire_throughput_multiplier", value = 2 },
	},
	kind = "protocol",
	tree_level = tlev,
	tree_line = 6,
})

-- software
ctw_technologies.register_technology("sgml", {
	name = S("SGML"),
	description = S("Enriched and formatted text that is human- and machine-readable."),
	year = 1980,
	requires = {
		"ascii"
	},
	conn_info = {ascii = {start_shift=0},},
	kind = "software",
	tree_level = tlev,
	tree_line = 9,
})

-- software
ctw_technologies.register_technology("enquire", {
	name = S("ENQUIRE"),
	description = S("Easy linkable documentation pages."),
	year = 1980,
	requires = {
		"ascii"
	},
	conn_info = {ascii = {start_shift=1},},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})

-- ==============
-- 1983 - 1984 --
-- ==============
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1983 - 1984"

-- hardware
ctw_technologies.register_technology("ethernet", {
	name = S("Ethernet Standard"),
	description = S("Standardized cables and data transfer"),
	year = 1983,
	requires = {
		"crc"
	},
	conn_info = {
		crc = {start_shift=0,end_shift=0},
	},
	benefits = {
		{ type = "supply", item="reseau:copper_%t_wire_00000000" }
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 1,
})

-- software
ctw_technologies.register_technology("gnu", {
	name = S("GNU"),
	description = S("The first steps towards a free Operating System."),
	year = 1983,
	requires = {
		"unix"
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 7,
})

-- hardware
ctw_technologies.register_technology("tokenring", {
	name = S("4Mbps Token Ring"),
	description = S("An IBM standard to connect computers."),
	year = 1984,
	requires = {
		"ipnet"
	},
	conn_info = {
		ipnet = {start_shift = 0}
	},
	benefits = {
		{ type = "wire_throughput_multiplier", value = 2 }
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 4,
})

-- service
ctw_technologies.register_technology("tangle", {
	name = S("Tangle"),
	description = S("?? ENQUIRE follow-up"),
	year = 1984,
	requires = {
		"enquire"
	},
	kind = "service",
	tree_level = tlev,
	tree_line = 10,
})

-- ==========
-- -- 1985 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1985"

-- hardware
ctw_technologies.register_technology("fiberproduction", {
	name = S("Fast Optical Fiber Production"),
	description = S("The commercial fiber industry is slowly getting started."),
	year = 1985,
	requires = {
		"fiber"
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 3,
})

-- service
ctw_technologies.register_technology("dns", {
	name = S("Domain Name Server"),
	description = S("This service translates computer addresses into friendly names."),
	year = 1985,
	requires = {
		"tcpip"
	},
	benefits = { -- more people use it now:
		{ type = "experiment_throughput_multiplier", value = 2 }
	},
	kind = "service",
	tree_level = tlev,
	tree_line = 6,
})

-- software
ctw_technologies.register_technology("grif", {
	name = S("GrIF SGML editor"),
	description = S("Tech savy people will love to create and edit SGML documents so easily."),
	year = 1985,
	requires = {
		"sgml"
	},
	conn_info = {
		sgml = {start_shift=0,end_shift=0},
		cerndoc = {start_shift=-0.5,end_shift=-1},
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 9,
})

-- software
ctw_technologies.register_technology("enquire2", {
	name = S("ENQUIRE v2"),
	description = S("?? what's changed?"),
	year = 1985,
	requires = {
		"tangle",
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
	tree_conn_loc = 2.9,
})

-- ==========
-- -- 1986 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1986"

-- kept for completeness


-- ==========
-- -- 1987 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1987"

-- hardware
ctw_technologies.register_technology("twistethernet", {
	name = S("Twisted Pair Ethernet"),
	description = S("Trash your coaxial cables and prepare for reliable high-frequency cables."),
	year = 1987,
	requires = {
		"ethernet",
		"e10base2"
	},
	conn_info = {
		ethernet = {start_shift=0,end_shift=0},
		e10base2 = {start_shift=0,end_shift=1,vertline_offset=2}
	},
	benefits = {
		{ type = "wire_throughput_multiplier", value = 5 },
		{ type = "receiver_throughput_multiplier", value = 3 },
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 1,
})

-- service
ctw_technologies.register_technology("gif", {
	name = S("GIF"),
	description = S("Lossless static or animated images. A great end-user experience."),
	year = 1987,
	requires = {
		"grif"
	},
	conn_info = {
		grif = {start_shift=-0.5,end_shift=-0.5},
	},
	benefits = {
		{ type = "experiment_throughput_multiplier", value = 2 }
	},
	kind = "service",
	tree_level = tlev,
	tree_line = 9,
})

-- software
ctw_technologies.register_technology("hypertext", {
	name = S("Hypertext"),
	description = S("Easy linkable content between different network computers."),
	year = 1987,
	requires = {
		"grif",
		"enquire2"
	},
	conn_info = {
		enquire2 = {start_shift=0.5,end_shift=0.5},
	},
	benefits = {
		{ type = "experiment_throughput_multiplier", value = 2 }
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})

-- ==========
-- -- 1988 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1988"

-- protocol
ctw_technologies.register_technology("dynroutingrip", {
	name = S("Dynamic Routing: RIP"),
	description = S("This technology provide the basics for connecting multiple network."),
	year = 1988,
	requires = {
		"twistethernet",
		"ipnet"
	},
	conn_info = {
		ipnet = {start_shift=1,end_shift=1},
		twistethernet={start_shift=2,end_shift=0}
	},
	kind = "protocol",
	tree_level = tlev,
	tree_line = 5,
})

-- ==========
-- -- 1989 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1989"

-- protocol
ctw_technologies.register_technology("dynroutingbgp", {
	name = S("Dynamic Routing: BGP"),
	description = S("The Border Gateway Protocol routes the packets based on paths and rules."),
	year = 1989,
	requires = {
		"dynroutingrip",
	},
	benefits = {
		{ type = "router_throughput_multiplier", value = 1.5 }
	},
	kind = "protocol",
	tree_level = tlev,
	tree_line = 4,
})

-- hardware
ctw_technologies.register_technology("merger", {
	name = S("Merge Router"),
	description = S("Merge various kinds of cables to improve the wire usage."),
	year = 1989,
	requires = {
		"dynroutingrip" -- or better
	},
	conn_info = {
		dynroutingrip = {start_shift=0.5,end_shift=0.5},
	},
	benefits = {
		{ type = "supply", item="reseau:merger_%t", time_min=80, time_max=180 },
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 5,
})

-- software
ctw_technologies.register_technology("gpl", {
	name = S("GNU General Public License"),
	description = S("A license to bring cooperation along. Share and modify code freely."),
	year = 1989,
	requires = {
		"gnu",
	},
	conn_info = {
		gnu = { start_shift = 1, end_shift = 1 }
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 8,
})

-- software
ctw_technologies.register_technology("hypertextproposal", {
	name = S("Memo about Hypertext"),
	description = S("A memo from Tim Berners-Lee. It's a proposal for linking files in the internet."),
	year = 1989,
	requires = {
		"dns",
		"hypertext"
	},
	conn_info = {
		dns = {start_shift=1,vertline_offset=1},
		hypertext = {start_shift=0.5,end_shift=0.5},
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})

-- ==========
-- -- 1990 -- v1
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1990"

-- hardware
ctw_technologies.register_technology("fibercommunications", {
	name = S("Fiberoptic Communications"),
	description = S("Market-ready data communication over fiber."),
	year = 1990,
	requires = {
		"twistethernet",
		"fiberproduction"
	},
	conn_info = {
		twistethernet = {start_shift=1},
		fiberproduction = {start_shift=0.5,end_shift=0.5},
	},
	benefits = {
		{ type = "supply", item="reseau:fiber_%t_00000000 50", time_min=60, time_max=120 },
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 3,
})

-- protocol
ctw_technologies.register_technology("http", {
	name = S("Hypertext Protocol"),
	description = S("Standardized format to request data from servers in the internet."),
	year = 1990,
	requires = {
		"hypertextproposal"
	},
	kind = "protocol",
	tree_level = tlev,
	tree_line = 9,
})

-- software
ctw_technologies.register_technology("html", {
	name = S("Hypertext Markup Language"),
	description = S("Standardized format to let browsers display websize contents."),
	year = 1990,
	requires = {
		"hypertextproposal"
	},
	conn_info = {
		hypertextproposal = {start_shift=0.5,end_shift=0.5},
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})

-- ==========
-- -- 1990 -- v2
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = ""

-- service
ctw_technologies.register_technology("httpd", {
	name = S("CERN Server Software"),
	description = S("This server is written Tim Berners-Lee to provide content to the browser requests."),
	year = 1990,
	requires = {
		"http"
	},
	kind = "service",
	tree_level = tlev,
	tree_line = 9,
})

-- software
ctw_technologies.register_technology("wwwbrowser", {
	name = S("WorldWideWeb Browser"),
	description = S("Tim Berners-Lee provides this browser as a foundation to browse on the internet."),
	year = 1990,
	requires = {
		"html"
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})


-- ==========
-- -- 1991 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1991"

-- hardware
ctw_technologies.register_technology("cat5", {
	name = S("Category 5 cable"),
	description = S("Standardized twisted-pair cable that is capable to deliver up to 100 Mbps."),
	year = 1991,
	requires = {
		"twistethernet"
	},
	conn_info = {
		twistethernet = {start_shift=0,end_shift=0},
	},
	benefits = {
		{ type = "wire_throughput_multiplier", value = 4 }
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 1,
})

-- software
ctw_technologies.register_technology("linux", {
	name = S("Linux"),
	description = S("To complete the GNU software, Linus Torvalds writes the first Linux kernel version."),
	year = 1991,
	requires = {
		"gnu"
	},
	conn_info = {
		gnu = { start_shift = 0, end_shift = 0 }
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 7,
})

-- software
ctw_technologies.register_technology("cernbook", {
	name = S("CERN Phonebook"),
	description = S("A revolutionary dictionary to look up phone numbers from a server."),
	year = 1991,
	requires = {
		"httpd"
	},
	conn_info = {
		httpd = {start_shift=-0.5,end_shift=0},
	},
	benefits = {
		{ type = "experiment_throughput_multiplier", value = 2 }
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 8,
})

-- software
ctw_technologies.register_technology("cernpage", {
	name = S("CERN Webpage"),
	description = S("The new official CERN webpage (info.cern.ch) presents current ongoing projects."),
	year = 1991,
	requires = {
		"httpd"
	},
	conn_info = {
		httpd = {start_shift=0.5,end_shift=0.5},
	},
	benefits = { -- scientists are happy
		{ type = "experiment_throughput_multiplier", value = 2 }
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 9,
})

-- software
ctw_technologies.register_technology("violawww", {
	name = S("ViolaWWW Browser"),
	description = S("This browser provides website styling, scripting and document embedding."),
	year = 1991,
	requires = {
		"wwwbrowser"
	},
	benefits = { -- amazing new stuff
		{ type = "experiment_throughput_multiplier", value = 1.5 }
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})

-- ==========
-- -- 1992 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1992"

-- hardware
ctw_technologies.register_technology("splitter", {
	name = S("Split Router"),
	description = S("Split various kinds of cables to improve the wire usage."),
	year = 1992,
	requires = {
		"merger", -- or better
		"linux",
		"dynroutingbgp",
	},
	conn_info = {
		dynroutingbgp = {start_shift=-1,end_shift=-1,vertline_offset=0.3},
		merger = {vertline_offset=0.2,end_shift=0},
		linux = {start_shift=-0.5,end_shift=1},
	},
	benefits = {
		{ type = "supply", item="reseau:splitter_%t", time_min=80, time_max=180 },
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 4,
})

-- software
ctw_technologies.register_technology("lynx", {
	name = S("Lynx Webbrowser"),
	description = S("This text-based browser was originally thought to share campus information. But it works to good."),
	year = 1992,
	requires = {
		"violawww" -- does not really depend on this one. make it a dead-end?
	},
	benefits = {
		{ type = "supply", item="reseau:splitter_%t", time_min=80, time_max=180 },
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})

-- ==========
-- -- 1993 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1993"

-- protocol
ctw_technologies.register_technology("cidrrouting", {
	name = S("Classless Inter-Domain Routing"),
	description = S("Introduce subnets to prevent running out of addresses for your network computers."),
	year = 1993,
	requires = {
		"splitter"
	},
	benefits = {
		{ type = "router_throughput_multiplier", value = 0.8 },
	},
	kind = "protocol",
	tree_level = tlev,
	tree_line = 5,
})

-- service
ctw_technologies.register_technology("gnn", {
	name = S("Global Network Navigator"),
	description = S("A joy for corporations. Advertise your goods on the world wide web."),
	year = 1993,
	requires = {
		"cernbook"
	},
	benefits = {
		{ type = "receiver_throughput_multiplier", value = 3 },
	},
	kind = "service",
	tree_level = tlev,
	tree_line = 8,
})

-- ??
ctw_technologies.register_technology("wwwpublic", {
	name = S("WWW in Public Domain"),
	-- TODO: Better description
	description = S("Everybody may use the world wide web, it is no longer for educational use."),
	year = 1993,
	requires = {
		"linux",
		"cernpage",
		"lynx"
	},
	kind = "??",
	tree_level = tlev,
	tree_line = 9,
})

-- software
ctw_technologies.register_technology("mosaic", {
	name = S("NCSA Mosaic Browser"),
	description = S("This brower is capable of display images within the page. Easy to install for oridianry users."),
	year = 1993,
	requires = {
		"lynx"
	},
	conn_info = {
		lynx = {start_shift=0.5,end_shift=0.5},
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})

-- ==========
-- -- 1994 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1994"

-- protocol
ctw_technologies.register_technology("url", {
	name = S("Uniform Resource Locator"),
	description = S("This standard describes how to address files on a webpage."),
	year = 1994,
	requires = {
		"dns",
		"gnn",
		"wwwpublic"
	},
	conn_info = {
		dns = {start_shift=0,end_shift=0},
		gnn = {start_shift=1, end_shift=1},
		wwwpublic = {start_shift=-0.5,end_shift=2}
	},
	kind = "protocol",
	tree_level = tlev,
	tree_line = 8,
})

-- software
ctw_technologies.register_technology("netscape", {
	name = S("Netscape"),
	description = S("Continued development of NCSA Mosaic with an easy webpage editor built-in ('Gold' version)."),
	year = 1994,
	requires = {
		"wwwpublic",
		"mosaic",
	},
	conn_info = {
		mosaic = {start_shift=0.5,end_shift=1.5},
		wwwpublic = {start_shift=0.5,end_shift=0.5},
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 9,
})

-- ==========
-- -- 1995 --
-- ==========
tlev = tlev + 1
ctw_technologies.year_captions[tlev] = "1995"

-- hardware
ctw_technologies.register_technology("fastethernet", {
	name = S("Fast Ethernet"),
	description = S("Twisted-pair or optical fiber wires that are capable to deliver 100 Mbps throughput."),
	year = 1995,
	requires = {
		"cat5"
	},
	benefits = {
		{ type = "wire_throughput_multiplier", value = 10 }
	},
	kind = "hardware",
	tree_level = tlev,
	tree_line = 2,
})

-- software TODO: Maybe delete?
ctw_technologies.register_technology("iexplore", {
	name = S("Internet Explorer"),
	description = S("Bad decisions were made. Your chance to repeat them."),
	year = 1995,
	requires = {
		"mosaic"
	},
	conn_info = {
		mosaic = {start_shift=1.5,end_shift=1.5},
	},
	benefits = {
		{ type = "experiment_throughput_multiplier", value = 0.8 }
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 10,
})

-- software
ctw_technologies.register_technology("png", {
	name = S("Portable Network Graphics"),
	description = S("Images with more than 256 different colors become common: an alternative for GIFs."),
	year = 1995,
	requires = {
		"gnn"
	},
	conn_info = {
		gnn = {start_shift=0,end_shift=0,vertline_offset=1.05},
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 7,
})

-- software
ctw_technologies.register_technology("w3c", {
	name = S("World Wide Web Consortium"),
	description = S("Tim Berners-Lee's organization to define standards in the world wide web."),
	year = 1995,
	requires = {
		"url",
		"netscape"
	},
	conn_info = {
		url = {start_shift=0,end_shift=0},
		netscape = {start_shift=1,end_shift=1}
	},
	kind = "software",
	tree_level = tlev,
	tree_line = 9,
})


-- TODO

--[[
	benefits = {
		{type="victory"}
	},
]]

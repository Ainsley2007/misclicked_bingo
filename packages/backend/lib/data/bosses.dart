const String bossesJson = '''
[
    {
        "name": "Kalphite Queen",
        "type": "EASY",
        "icon": "https://i.imgur.com/P2oQdZI.png",
        "uniques": [
            "Dragon pickaxe",
            "Kq head",
            "Jar of sand",
            "Kalphite princess",
            "Dragon 2h sword"
        ]
    },
    {
        "name": "King Black Dragon",
        "type": "EASY",
        "icon": "https://i.imgur.com/gcjgc5m.png",
        "uniques": [
            "Dragon pickaxe",
            "Kbd heads",
            "Prince black dragon",
            "Draconic visage"
        ]
    },
    {
        "name": "Duke Sucellus",
        "type": "SOLO",
        "icon": "https://i.imgur.com/1O3UiIU.png",
        "uniques": [
            "Magus vestige",
            "Eye of the duke",
            "Virtus mask",
            "Virtus robe top",
            "Virtus robe bottom",
            "Ice quartz",
            "Baron"
        ]
    },
    {
        "name": "The Leviathan",
        "type": "SOLO",
        "icon": "https://i.imgur.com/NlZZmK7.png",
        "uniques": [
            "Venator vestige",
            "Leviathan's lure",
            "Virtus mask",
            "Virtus robe top",
            "Virtus robe bottom",
            "Smoke quartz",
            "Lil'viathan"
        ]
    },
    {
        "name": "The Whisperer",
        "type": "SOLO",
        "icon": "https://i.imgur.com/F1h8f4a.png",
        "uniques": [
            "Bellator vestige",
            "Siren's staff",
            "Virtus mask",
            "Virtus robe top",
            "Virtus robe bottom",
            "Shadow quartz",
            "Wisp"
        ]
    },
    {
        "name": "Vardorvis",
        "type": "SOLO",
        "icon": "https://i.imgur.com/YvUebDV.png",
        "uniques": [
            "Ultor vestige",
            "Executioner's axe head",
            "Virtus mask",
            "Virtus robe top",
            "Virtus robe bottom",
            "Blood quartz",
            "Butch"
        ]
    },
    {
        "name": "Giant Mole",
        "type": "EASY",
        "icon": "https://i.imgur.com/FSdFVPV.png",
        "uniques": [
            "Baby mole",
            "Curved bone"
        ]
    },
    {
        "name": "Sarachnis",
        "type": "EASY",
        "icon": "https://i.imgur.com/UeSiSzz.png",
        "uniques": [
            "Sarachnis cudgel",
            "Jar of eyes",
            "Sraracha"
        ]
    },
    {
        "name": "Zulrah",
        "type": "SOLO",
        "icon": "https://i.imgur.com/5jvptQM.png",
        "uniques": [
            "Tanzanite fang",
            "Magic fang",
            "Serpentine visage",
            "Uncut onyx",
            "Tanzanite mutagen",
            "Magma mutagen",
            "Jar of swamp",
            "Pet snakeling"
        ]
    },
    {
        "name": "The Gauntlet",
        "type": "SOLO",
        "icon": "https://i.imgur.com/f0awlhF.png",
        "uniques": [
            "Crystal weapon seed",
            "Crystal armour seed",
            "Enhanced crystal weapon seed",
            "Youngleff"
        ]
    },
    {
        "name": "Vorkath",
        "type": "SOLO",
        "icon": "https://i.imgur.com/y7mZwSN.png",
        "uniques": [
            "Vorkath's head",
            "Dragonbone necklace",
            "Vorki",
            "Draconic visage",
            "Skeletal visage",
            "Jar of decay"
        ]
    },
    {
        "name": "Scurrius",
        "type": "SOLO",
        "icon": "https://i.imgur.com/uNTEHsL.png",
        "uniques": [
            "Scurry",
            "Curved bone"
        ]
    },
    {
        "name": "Theatre of Blood",
        "type": "GROUP",
        "icon": "https://i.imgur.com/ZsShm4R.png",
        "uniques": [
            "Avernic defender hilt",
            "Ghrazi rapier",
            "Sanguinesti staff",
            "Justiciar faceguard",
            "Justiciar chestguard",
            "Justiciar legguards",
            "Scythe of vitur"
        ]
    },
    {
        "name": "Royal Titans",
        "type": "GROUP",
        "icon": "https://i.imgur.com/eBJAPmX.png",
        "uniques": [
            "Fire elemental staff crown",
            "Ice elemental staff crown",
            "Bran"
        ]
    },
    {
        "name": "Phantom Muspah",
        "type": "SOLO",
        "icon": "https://i.imgur.com/IF2kp0N.png",
        "uniques": [
            "Venator shard",
            "Muphin"
        ]
    },
    {
        "name": "The Nightmare",
        "type": "SOLO",
        "icon": "https://i.imgur.com/vK0gpAK.png",
        "uniques": [
            "Nightmare staff",
            "Inquisitor's great helm",
            "Inquisitor's hauberk",
            "Inquisitor's plateskirt",
            "Inquisitor's mace",
            "Eldritch orb",
            "Harmonised orb",
            "Volatile orb",
            "Jar of dreams",
            "Little nightmare"
        ]
    },
    {
        "name": "Doom of Mokhaiotl",
        "type": "SOLO",
        "icon": "https://i.imgur.com/0uNTrzs.png",
        "uniques": [
            "Avernic treads",
            "Eye of ayak",
            "Mokhaiotl cloth",
            "Dom"
        ]
    },
    {
        "name": "Fortis Colosseum",
        "type": "SOLO",
        "icon": "https://i.imgur.com/TOLk5sc.png",
        "uniques": [
            "Dizana's quiver",
            "Echo crystal",
            "Uncut onyx",
            "Sunfire fanatic helm",
            "Sunfire fanatic cuirass",
            "Sunfire fanatic chausses",
            "Tonalztics of ralos",
            "Smol heredit"
        ]
    },
    {
        "name": "Chamber of Xeric",
        "type": "GROUP",
        "icon": "https://i.imgur.com/wiktAcE.png",
        "uniques": [
            "Dexterous prayer scroll",
            "Arcane prayer scroll",
            "Twisted buckler",
            "Dragon hunter crossbow",
            "Dinh's bulwark",
            "Ancestral hat",
            "Ancestral robe top",
            "Ancestral robe bottom",
            "Dragon claws",
            "Elder maul",
            "Kodai insignia",
            "Twisted bow",
            "Olmlet",
            "Twisted ancestral colour kit",
            "Metamorphic dust"
        ]
    },
    {
        "name": "Yama",
        "type": "GROUP",
        "icon": "https://i.imgur.com/SpPL7sR.png",
        "uniques": [
            "Soulflame horn",
            "Oathplate helm",
            "Oathplate body",
            "Oathplate legs",
            "Yami"
        ]
    },
    {
        "name": "Abyssal Sire",
        "type": "SLAYER",
        "icon": "https://i.imgur.com/3Gpowbx.png",
        "uniques": [
            "Unsired"
        ]
    },
    {
        "name": "Arraxor",
        "type": "SLAYER",
        "icon": "https://i.imgur.com/7mYvZVD.png",
        "uniques": [
            "Noxious pommel",
            "Noxious point",
            "Noxious blade",
            "Araxyte fang",
            "Araxyte head",
            "Jar of venom",
            "Nid"
        ]
    },
    {
        "name": "Cerberus",
        "type": "SLAYER",
        "icon": "https://i.imgur.com/cbFH5Rs.png",
        "uniques": [
            "Primordial crystal",
            "Pegasian crystal",
            "Eternal crystal",
            "Smouldering stone",
            "Jar of souls",
            "Hellpuppy"
        ]
    },
    {
        "name": "Amoxliatl",
        "type": "SOLO",
        "icon": "https://i.imgur.com/5FuiY0G.png",
        "uniques": [
            "Glacial temotli",
            "Moxi"
        ]
    },
    {
        "name": "Tombs of Amascut",
        "type": "GROUP",
        "icon": "https://i.imgur.com/owJX9tb.png",
        "uniques": [
            "Osmumten's fang",
            "Lightbearer",
            "Elidins' ward",
            "Masori mask",
            "Masori body",
            "Masori chaps",
            "Tumeken's shadow",
            "Tumeken's guardian"
        ]
    },
    {
        "name": "Nex",
        "type": "GROUP",
        "icon": "https://i.imgur.com/G4R4PnK.png",
        "uniques": [
            "Zaryte vambraces",
            "Nihil horn",
            "Torva full helm",
            "Torva platebody",
            "Torva platelegs",
            "Ancient hilt",
            "Nexling"
        ]
    },
    {
        "name": "Thermonuclear smoke devil",
        "type": "SLAYER",
        "icon": "https://i.imgur.com/IEqsucq.png",
        "uniques": [
            "Occult necklace",
            "Smoke battlestaff",
            "Dragon chainbody",
            "Jar of smoke",
            "Pet smoke devil"
        ]
    },
    {
        "name": "Alchemical Hydra",
        "type": "SLAYER",
        "icon": "https://i.imgur.com/xZTSoTu.png",
        "uniques": [
            "Hydra leather",
            "Hydra's claw",
            "Alchemical hydra heads",
            "Jar of chemicals",
            "Ikkle hydra"
        ]
    },
    {
        "name": "Grotesque Guardians",
        "type": "SLAYER",
        "icon": "https://i.imgur.com/Eu2IAWx.png",
        "uniques": [
            "Granite hammer",
            "Granite ring",
            "Granite gloves",
            "Black tourmaline core",
            "Jar of stone",
            "Noon"
        ]
    },
    {
        "name": "Kraken",
        "type": "SLAYER",
        "icon": "https://i.imgur.com/MDBVKg2.png",
        "uniques": [
            "Trident of the seas",
            "Kraken tentacle",
            "Jar of dirt",
            "Pet kraken"
        ]
    }
]''';

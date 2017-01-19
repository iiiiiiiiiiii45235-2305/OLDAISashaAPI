local ESEMPIO = 
{
  about = "test",
  access_hash = -6.8497743629159e+18,
  admins_count = 4,
  can_set_username = false,
  can_view_participants = true,
  democracy = true,
  first_name = "\U0001f3ae Test Group \u2615\ufe0f",
  id = -1001031209686,
  kicked_count = 6,
  last_update = 1484859072,
  participants = {
    {
      date = 1475264730,
      inviter = {
        access_hash = 8.7659463919353e+18,
        first_name = "Sasha",
        id = 149998353,
        last_name = "A.I.",
        restricted = false,
        status = {
          _ = "userStatusOnline",
          expires = 1484859459
        },
        type = "user",
        username = "AISasha",
        verified = false
      },
      role = "moderator",
      user = {
        access_hash = -7.9989917793598e+18,
        first_name = "Eric",
        id = 41400331,
        last_name = "OTI Cancer Solinas",
        restricted = false,
        status = {
          _ = "userStatusRecently"
        },
        type = "user",
        username = "EricSolinas",
        verified = false
      }
    },
    {
      date = 1481751776,
      inviter = {
        access_hash = 8.7659463919353e+18,
        first_name = "Sasha",
        id = 149998353,
        last_name = "A.I.",
        restricted = false,
        status = {
          _ = "userStatusOnline",
          expires = 1484859459
        },
        type = "user",
        username = "AISasha",
        verified = false
      },
      role = "moderator",
      user = {
        access_hash = 3.1994369395494e+18,
        first_name = "Sasha A.I.",
        id = 283058260,
        restricted = false,
        type = "bot",
        username = "AISashaBot",
        verified = false
      }
    },
    {
      date = 1481752069,
      role = "user",
      user = {
        access_hash = -7.5057240319811e+18,
        first_name = "Ganjalf |senza trapano|",
        id = 286855451,
        last_name = "(Murtah lives)",
        restricted = false,
        status = {
          _ = "userStatusOnline",
          expires = 1484859383
        },
        type = "user",
        username = "Harakkak",
        verified = false
      }
    },
    {
      date = 1483623485,
      role = "user",
      user = {
        access_hash = 6.9650003237737e+18,
        first_name = "umbi",
        id = 189199922,
        restricted = false,
        status = {
          _ = "userStatusOnline",
          expires = 1484859394
        },
        type = "user",
        username = "umbit",
        verified = false
      }
    },
    {
      date = 1481828420,
      role = "user",
      user = {
        access_hash = -8.7723268163288e+18,
        first_name = "Mr",
        id = 159788990,
        last_name = "\U0001f308Simona\U0001f308",
        restricted = false,
        status = {
          _ = "userStatusOffline",
          was_online = 1484859082
        },
        type = "user",
        username = "quello_stronzo",
        verified = false
      }
    },
    {
      role = "creator",
      user = {
        access_hash = 8.7659463919353e+18,
        first_name = "Sasha",
        id = 149998353,
        last_name = "A.I.",
        restricted = false,
        status = {
          _ = "userStatusOnline",
          expires = 1484859459
        },
        type = "user",
        username = "AISasha",
        verified = false
      }
    },
    {
      date = 1481752826,
      role = "user",
      user = {
        access_hash = -8.2934067955326e+18,
        first_name = "Always\U0001f496 (83 11)",
        id = 165005704,
        restricted = false,
        status = {
          _ = "userStatusRecently"
        },
        type = "user",
        username = "Imthequeen99",
        verified = false
      }
    },
    {
      date = 1481752035,
      role = "user",
      user = {
        access_hash = 6.395878427014e+17,
        first_name = "MrF(Killu\U0001f577\ufe0f\U0001f577\ufe0f)",
        id = 33302924,
        last_name = "                                                                                                                                                                                                                                                               ",
        restricted = false,
        status = {
          _ = "userStatusOffline",
          was_online = 1484859133
        },
        type = "user",
        username = "FrancoFre",
        verified = false
      }
    },
    {
      date = 1478705622,
      role = "user",
      user = {
        access_hash = 5.7620155931715e+18,
        id = 289741153,
        restricted = false,
        type = "user",
        verified = false
      }
    },
    {
      date = 1471184887,
      role = "user",
      user = {
        access_hash = 8.8058539736368e+18,
        first_name = "Privè",
        id = 206056435,
        restricted = false,
        type = "bot",
        username = "LGP_bot",
        verified = false
      }
    },
    {
      date = 1458935909,
      inviter = {
        access_hash = 8.7659463919353e+18,
        first_name = "Sasha",
        id = 149998353,
        last_name = "A.I.",
        restricted = false,
        status = {
          _ = "userStatusOnline",
          expires = 1484859459
        },
        type = "user",
        username = "AISasha",
        verified = false
      },
      role = "moderator",
      user = {
        access_hash = -1.1729859909386e+18,
        first_name = "Lollo\u270c\U0001f60f",
        id = 155159899,
        restricted = false,
        status = {
          _ = "userStatusOffline",
          was_online = 1484859103
        },
        type = "user",
        username = "IlKingOttas",
        verified = false
      }
    }
  },
  participants_count = 11,
  restricted = false,
  signatures = false,
  title = "\U0001f3ae Test Group \u2615\ufe0f",
  type = "supergroup",
  username = "SupergroupTest"
}

local function run(msg, matches)
    if is_sudo(msg) then
        return vardumptext(resolveChannelSupergroupsUsernames(matches[1]))
    end
end

return {
    description = "TEST",
    patterns =
    {
        "^[#!/][Gg][Ee][Tt][Cc][Hh][Aa][Tt] (.*)",
    },
    run = run,
    min_rank = 4,
    syntax =
    {
    }
}
import mysql.connector
import discord
import os
from discord.ext import commands
import vars
from discord import File
import discord.utils
from PIL import Image, ImageDraw, ImageFont
import io

client = commands.Bot(command_prefix='=', case_insensitive=True)

config = {
  'user': vars.USERNAME,
  'password': vars.PASSWORD,
  'host': vars.HOSTNAME,
  'database': vars.DATABASE,
  'raise_on_warnings': True
}

def connectdatabase():
  try:
      cnx = mysql.connector.connect(**config)
      cursor = cnx.cursor()
      print("MySQL Connection Created Successfully")
  except Exception as e:
      print(e)
      print("Exitting...")
      exit()

  def exec(query):
      try:
          cursor.execute(query)
          return cursor.fetchall()
      except Exception as e:
          return str(e)


@client.event
async def on_ready():
    print('Bot is running')
    await client.change_presence(activity=discord.Game(name="Remembering Asiania RPG..."))

@client.event
async def on_command_error(ctx, error):
    if isinstance(error, commands.CommandNotFound):
        await ctx.send("You entered an invalid command. Try =help to see list of commands.")

@client.command()
@commands.has_permissions(manage_messages=True)
async def clear(ctx, amount=5):
  await ctx.channel.purge(limit = amount)


@client.command(aliases=['online', 'total'])
async def players(ctx):
    await ctx.send('Asiania RPG has been shut down. Thanks for playing.')
    return
    if ctx.channel.id != 785130478474493952:
      await ctx.send('Wrong channel. Use this command in <#785130478474493952>.')
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    sql = "SELECT * FROM users WHERE isonline = '1'"
    cursor.execute(sql)
    total="Name - Level\n"
    substring=""
    deleted_row_count = cursor.rowcount
    if not deleted_row_count:
      await ctx.send("There's no one online.")
      return
    players=0;
    for row in cursor:
        name = row[1]
        level = row[11]
        substring= f'\n{name} - {level}'
        total =  total + substring
        players += 1
    await ctx.send(f'```{total}\n\nTotal: {players} | Asiania RPG | https://axiania.com | 51.79.204.126:7777```')
    cursor.close()
    cnx.close()

@client.command()
async def mostgifts(ctx):
    await ctx.send('Server is closed. Maybe we will see you again in future..Maybe. Thanks for playing!')
    return
    if ctx.channel.id != 785130478474493952:
      if not ctx.message.author.guild_permissions.manage_messages:
        await ctx.send('Wrong channel. Use this command in <#785130478474493952>.')
        return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    sql = "SELECT * FROM users WHERE `gifts` > '0' ORDER BY `gifts` DESC LIMIT 10"
    cursor.execute(sql)
    total="Name - Gifts\n"
    substring=""
    deleted_row_count = cursor.rowcount
    if not deleted_row_count:
      await ctx.send("No one collected gifts yet.")
      return
    players=0;
    for row in cursor:
        name = row[1]
        level = row[203]
        substring= f'\n{name} - {level}'
        total =  total + substring
        players += 1
    await ctx.send(f'```{total}\n\nGifts Leaderboard | Fall Festival```')
    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def record(ctx, *, name=None):
    if not name:
      await ctx.send("=record [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("SELECT * FROM users WHERE p_name = %s", (name, ))
    myresult = cursor.fetchall()
    if not  myresult:
      await ctx.send("Couldnot find the specified name in the database.")
      return
    for x in myresult:
      userid = x[0]
    admin_name="None"
    reason = "None"
    cursor.execute("SELECT record.*, users.p_name AS admin_name FROM record LEFT JOIN users ON record.admin_id = users.user_id WHERE punished_id = %s", (userid, ))
    myresult = cursor.fetchall()
    if not  myresult:
      await ctx.send("Couldnot find any record on specified name.")
      return

    total=""
    substring=""
    rowcount = 1
    for x in myresult:
      admin_name=x[6]
      reason = x[2]
      punishid = x[0]
      typeofpunishment = x[5]
      punishment = f'{rowcount}. [SqlID: {punishid}] Name: {name} | Punished by: {admin_name} | Type: {typeofpunishment} | Reason: {reason}\n\n'
      total = total+punishment
      rowcount +=1

    filename = f'{name} Record.txt'
    with open(filename, 'w') as f:
        f.write(total)
        f.close()
    
    await ctx.send(file=discord.File(filename))
    os.remove(filename)

    cursor.close()
    cnx.close()


@client.command()
@commands.has_permissions(manage_messages=True)
async def names(ctx, *, name=None):
    if not name:
      await ctx.send("=name [Name]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("SELECT * FROM namehistory WHERE log LIKE CONCAT('%', %s, '%') LIMIT 1", (name, ))
    myresult = cursor.fetchall()
    if not  myresult:
      await ctx.send("There is no name history on specified name.")
      return
    for x in myresult:
      userid=x[2]

    cursor.execute("SELECT * FROM namehistory WHERE user_id = %s", (userid, ))
    total = ""
    myresult = cursor.fetchall()
    for x in myresult:
      log=x[1]
      total = total + log + '\n'

    filename = f'{name}_Names.txt'
    with open(filename, 'w') as f:
        f.write(total)
        f.close()
    await ctx.send(file=discord.File(filename))
    os.remove(filename)

    cursor.close()
    cnx.close()


@client.command()
@commands.has_permissions(manage_messages=True)
async def expunge(ctx, *, name=None):
    if not name:
      await ctx.send("=expunge [Punishment ID]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("DELETE FROM record WHERE punish_ID = %s", (name, ))
    deleted_row_count = cursor.rowcount
    if not deleted_row_count:
      await ctx.send("Couldnot find a punishment with that ID.")
      return
    cnx.commit()
    await ctx.send("You have successfully expunged the specified punishment.")

    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def unban(ctx, *, name=None):
    if not name:
      await ctx.send("=unban [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("DELETE FROM banned WHERE user_name = %s", (name, ))
    deleted_row_count = cursor.rowcount
    if not deleted_row_count:
      await ctx.send("Couldnot find a banned player with that name.")
      return
    cnx.commit()
    await ctx.send("You have successfully unbanned the specified player.")

    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def whitelist(ctx, *, name=None):
    if not name:
      await ctx.send("=whitelist [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("SELECT * FROM whitelist WHERE p_name = %s", (name, ))
    myresult = cursor.fetchall()
    if myresult:
      await ctx.send("Player already exists in the database.")
      return
    cursor.execute("INSERT INTO whitelist (p_name) VALUES (%s)", (name, ))
    cnx.commit()
    await ctx.send(f'You have successfully added {name} to whitelist.')
    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def acremove(ctx, *, name=None):
    if not name:
      await ctx.send("=acremove [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()

    cursor.execute("SELECT * FROM users WHERE p_name = %s", (name, ))
    myresult = cursor.fetchall()
    if not myresult:
      await ctx.send("Couldnot find a registered user with that name.")
      return
    cursor.execute("UPDATE users SET acforced = '0' WHERE p_name = %s", (name, ))
    cnx.commit()
    await ctx.send(f'You have successfully removed {name} from launcher.')
    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def acforce(ctx, *, name=None):
    if not name:
      await ctx.send("=acforce [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()

    cursor.execute("SELECT * FROM users WHERE p_name = %s", (name, ))
    myresult = cursor.fetchall()
    if not myresult:
      await ctx.send("Couldnot find a registered user with that name.")
      return
    cursor.execute("UPDATE users SET acforced = '1' WHERE p_name = %s", (name, ))
    cnx.commit()
    await ctx.send(f'You have successfully added {name} to launcher list.')
    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def vpnlist(ctx, *, name=None):
    if not name:
      await ctx.send("=vpnlist [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("SELECT * FROM vpnlist WHERE p_name = %s", (name, ))
    myresult = cursor.fetchall()
    if myresult:
      await ctx.send("Player already exists in the VPN list.")
      return
    cursor.execute("INSERT INTO vpnlist (p_name) VALUES (%s)", (name, ))
    cnx.commit()
    await ctx.send(f'You have successfully added {name} to vpn list.')
    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def removevpnlist(ctx, *, name=None):
    if not name:
      await ctx.send("=removevpnlist [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("DELETE FROM vpnlist WHERE p_name = %s", (name, ))
    deleted_row_count = cursor.rowcount
    if not deleted_row_count:
      await ctx.send("Couldnot find a vpn list player with that name.")
      return
    cnx.commit()
    await ctx.send(f"You have successfully removed {name} from vpn list.")

    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def removewhitelist(ctx, *, name=None):
    if not name:
      await ctx.send("=removewhitelist [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("DELETE FROM whitelist WHERE p_name = %s", (name, ))
    deleted_row_count = cursor.rowcount
    if not deleted_row_count:
      await ctx.send("Couldnot find a whitelisted player with that name.")
      return
    cnx.commit()
    await ctx.send(f"You have successfully removed {name} from whitelist.")

    cursor.close()
    cnx.close()

@client.command()
@commands.has_permissions(manage_messages=True)
async def checkban(ctx, *, name=None):
    if not name:
      await ctx.send("=checkban [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("SELECT * FROM banned WHERE user_name = %s", (name, ))
  
    myresult = cursor.fetchall()
    if not  myresult:
      message=f'``{name} is not banned.``'
      await ctx.send(message)
      return
    for x in myresult:
      admin=x[5]
      reason=x[4]
    message=f'``{name} is banned by {admin}. Reason: {reason}``'
    await ctx.send(message)

    cursor.close()
    cnx.close()

BASEDIR = "/home/ogp_agent/OGP_User_Files/port_5333/scriptfiles/Ostalo"

@client.command()
@commands.has_permissions(manage_messages=True)
async def logs(ctx, type=None, date=None, name=None):
    if not name:
      await ctx.send("=logs [type] [date]  [search]")
      return
    if not type:
      await ctx.send("=logs [type] [date]  [search]")
      return
    if not date:
      await ctx.send("=logs [type] [date] [search]")
      return
    if type == "b":
        list_open = open(os.path.join(BASEDIR, 'LogBChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'OOC logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "l":
        list_open = open(os.path.join(BASEDIR, 'LogICChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Local IC logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "s":
        list_open = open(os.path.join(BASEDIR, 'LogSChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Shout logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "w":
        list_open = open(os.path.join(BASEDIR, 'LogWChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Whisper logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "cw":
        list_open = open(os.path.join(BASEDIR, 'LogCChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Vehicle whisper logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "wt":
        list_open = open(os.path.join(BASEDIR, 'LogWT.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Walkie Talkie logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "kill":
        list_open = open(os.path.join(BASEDIR, 'DeathLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Kill logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "pm":
        list_open = open(os.path.join(BASEDIR, 'LogAODG.log'), encoding="utf8")
        line = list_open.readline()
        total=f'PM logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "me":
        list_open = open(os.path.join(BASEDIR, 'ActionLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Action(ME) logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "attempt":
        list_open = open(os.path.join(BASEDIR, 'AttemptLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Attempt logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "do":
        list_open = open(os.path.join(BASEDIR, 'DoLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Action(DO) logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line)
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)


    elif type == "hit":
        list_open = open(os.path.join(BASEDIR, 'HitLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Damage logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line) + '\n'
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "weapon":
        list_open = open(os.path.join(BASEDIR, 'WeaponLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Weapon logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line) + '\n'
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "disconnect":
        list_open = open(os.path.join(BASEDIR, 'Disconnect.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Disconnection logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line) + '\n'
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "connect":
        list_open = open(os.path.join(BASEDIR, 'Connect.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Connection logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line) + '\n'
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "buy":
        list_open = open(os.path.join(BASEDIR, 'Purchase.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Purchase logs containing word {name}\n'
        while line:
            line = list_open.readline()
            if name in line and date in line:
                total =  total + str(line) + '\n'
        list_open.close()
        filename = f'{name}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

@client.command()
@commands.has_permissions(manage_messages=True)
async def wholelogs(ctx, type=None, date=None):
    if not type:
      await ctx.send("=wholelogs [type] [date]")
      return
    if not date:
      await ctx.send("=wholelogs [type] [date")
      return
    if type == "b":
        list_open = open(os.path.join(BASEDIR, 'LogBChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'OOC logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "l":
        list_open = open(os.path.join(BASEDIR, 'LogICChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Local IC logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "s":
        list_open = open(os.path.join(BASEDIR, 'LogSChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Shout logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "w":
        list_open = open(os.path.join(BASEDIR, 'LogWChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Whisper logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "cw":
        list_open = open(os.path.join(BASEDIR, 'LogCChat.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Vehicle whisper logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "wt":
        list_open = open(os.path.join(BASEDIR, 'LogWT.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Walkie Talkie logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "pm":
        list_open = open(os.path.join(BASEDIR, 'LogAODG.log'), encoding="utf8")
        line = list_open.readline()
        total=f'PM logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)
        
    elif type == "me":
        list_open = open(os.path.join(BASEDIR, 'ActionLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Action(ME) logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "attempt":
        list_open = open(os.path.join(BASEDIR, 'AttemptLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Attempt logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)

    elif type == "do":
        list_open = open(os.path.join(BASEDIR, 'DoLogs.log'), encoding="utf8")
        line = list_open.readline()
        total=f'Action(DO) logs containing for date {date}\n'
        while line:
            line = list_open.readline()
            if date in line:
                total =  total + str(line)
        list_open.close()
        date = date.replace("/", "-")
        filename = f'{date}.txt'
        with open(filename, 'w') as f:
            f.write(total)
            f.close()
        await ctx.send(file=discord.File(filename))
        os.remove(filename)



@client.command(aliases=['signature', 'sig'])
async def stats(ctx,*, name=None ):
    if not name:
      await ctx.send("=stats [Firstname_LastName]")
      return
    cnx = mysql.connector.connect(**config)
    cursor = cnx.cursor()
    cursor.execute("SELECT * FROM users WHERE p_name = %s", (name, ))
    
    myresult = cursor.fetchall()
    if not  myresult:
      await ctx.send("Couldnot find the specified name in the database.")
      return

    bank = 0
    for x in myresult:
      user_id = x[0]
      playername=x[1]
      level=x[11]
      money=x[10]
      hours=x[38]
      lastlogin=x[52]
      skin=x[17]

    cursor.execute("SELECT * FROM bank WHERE bankOwner = %s LIMIT 5", (user_id, ))
    
    for row in cursor:
        bank = bank + row[1]


    SKIN_SIZE = 256
    AVATAR_SIZE = 256
    background_image = Image.open('bg123.png') 
    background_image = background_image.convert('RGBA')
    image = background_image.copy()

    image_width, image_height = image.size



    draw = ImageDraw.Draw(image) 
    text = f'Name: {playername}'
    font = ImageFont.truetype("goodtimes.ttf", 45, encoding="unic")

    text_width, text_height = draw.textsize(text, font=font)


    draw.text((460, 100), text, fill=(255,255,255,255), font=font)
    text = f'Level: {level}'
    draw.text((460, 200), text, fill=(255,255,255,255), font=font)
    text = f'Cash: {money}$'
    draw.text((460, 300), text, fill=(255,255,255,255), font=font)
    text = f'Bank: {bank}$'
    draw.text((460, 400), text, fill=(255,255,255,255), font=font)
    text = f'Hours Played: {hours}'
    draw.text((460, 500), text, fill=(255,255,255,255), font=font)
    text = f'Last Login: {lastlogin}'
    draw.text((460, 600), text, fill=(255,255,255,255), font=font)


    imagelink = f'skins/{skin}.png'
    avatar_image= Image.open(imagelink)
    avatar_image = avatar_image.convert('RGBA')
    avatar_image = avatar_image.resize((350, 800)) 
    image.paste(avatar_image, (0, 0), avatar_image)


    buffer_output = io.BytesIO()
    image.save(buffer_output, format='PNG')
    buffer_output.seek(0)
    await ctx.send(file=File(buffer_output, f'{name}.png'))
    cursor.close()
    cnx.close()

client.run('YOURTOKEN')

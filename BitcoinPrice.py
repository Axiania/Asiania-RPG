import requests
import os
import time

loc = "/home/ogp_agent/OGP_User_Files/port_5333/scriptfiles/btc.txt"

while True:
    try:
        response = requests.get('https://api.coindesk.com/v1/bpi/currentprice.json')
    except:
        print("Api seems to be down");
    else:
        data = response.json()
        price = data["bpi"]["USD"]["rate"]
        price = price.replace(",", "")
        with open(loc, "w") as f:
            f.write("")
            f.write(price)
            f.close()
        print("New value of BTC written succesfully!")
    finally:
        time.sleep(600)
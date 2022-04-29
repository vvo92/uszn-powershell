import asyncio
import aiohttp
import datetime
import json
import pathlib
import os

async def ws_req():
    async with aiohttp.ClientSession() as session:
        async with session.ws_connect('ws://localhost:11111') as ws:
            await ws.send_json({'id': 2, 'command': "sign", 'data': "MDUzNzYwNjU=", 'pin': "3882", 'storeContent': "true", 'includeCert': "true", 'useStamp': "false"})
            #print((await ws.receive_json())['data']['data'])
            return (await ws.receive_json())['data']['data']


async def get_auth(cryptosrvip, username, userpassword):
    URL = 'http://{0}:96/idp/rest/user/login'.format(cryptosrvip)
    sign_data = await ws_req()
    async with aiohttp.ClientSession() as session:
        async with session.post(URL, json={'api': "authApi", 'username': username, 'password': userpassword, 'sign': sign_data, 'sandbox': 0}) as response:
            return (response.cookies['PHPSESSID'].value)


async def get_ips(url, phpsessid):
    cookies = {'PHPSESSID': phpsessid}
    async with aiohttp.ClientSession(cookies=cookies) as session:
        async with session.get(url) as response:
            #print(await response.json(content_type=None))
            with open(r".\jsons\IPS_{0}.json".format(url[-10:]), "wb") as out:
                async for chunk in response.content.iter_chunked(4096):
                    out.write(chunk)    


def gen_date_range(fromdate, tilldate):
    date_generated = [fromdate + datetime.timedelta(days=x) for x in range(0, (tilldate-fromdate).days + 1)]
    dayArr = []
    for day in date_generated:
        dayArr.append(day.strftime('%d.%m.%Y'))
    print(dayArr)
    return dayArr


def gen_urls(cryptosrvip, daysArr, district):
    urlsArr = []
    for day in daysArr:
        url = ('http://{0}:96/idp/application/search?mode=list&region={1}&district={2}&state=50&from={3}&till={4}'.format(cryptosrvip, district[0:2], district, day, day))
        urlsArr.append(url)
    print(urlsArr)
    return urlsArr


async def get_dov(url, session):
    #print(url)
    #cookies = {'PHPSESSID': phpsessid}
    #conn = aiohttp.TCPConnector(limit=1)
    
    #while True:
    #    try:
    #async with aiohttp.ClientSession(cookies=cookies) as session:
    
        async with session.get(url) as response:
        
                #print(await response.json(content_type=None))
            with open(r".\jsons\dovydka_{0}.json".format(url.split('/')[6]), "wb") as out:
                async for chunk in response.content.iter_chunked(4096):
                    out.write(chunk)
        
    #    except:
    #        await asyncio.sleep(1)


async def main(cryptosrvip, username, userpassword, urlsArr):
    PHPSESSID = await get_auth(cryptosrvip, username, userpassword)
    print(PHPSESSID)
    tasks = set()
    for url in urlsArr:
        task = asyncio.create_task(get_ips(url, PHPSESSID))
        tasks.add(task)
    await asyncio.gather(*tasks)
    #print(tasks)
    
async def main2(CRYPTOSRVIP, USERNAME, USERPASSWORD, DovsUrl):
    PHPSESSID = await get_auth(CRYPTOSRVIP, USERNAME, USERPASSWORD)
    
        
    cookies = {'PHPSESSID': PHPSESSID}
    
    async with aiohttp.ClientSession(cookies=cookies) as session:
        tasks = set()
        for url in DovsUrl:
            task = asyncio.create_task(get_dov(url, session))
            tasks.add(task)
        await asyncio.gather(*tasks)
    

if __name__ == '__main__':
    CRYPTOSRVIP = '127.0.0.1'
    USERNAME = ''
    USERPASSWORD = ''
    FROMDATE = datetime.date(2022, 2, 24)
    TILLDATE = datetime.date.today()
    if not os.path.exists(r'.\jsons'):
        os.makedirs('.\jsons')
    #asyncio.run(main(CRYPTOSRVIP, USERNAME, USERPASSWORD, gen_urls(CRYPTOSRVIP, gen_date_range(FROMDATE, TILLDATE), '1619')))
    DovsUrl = []
    for json_f in os.listdir(r'.\jsons'):
        if json_f[:3] == 'IPS':
            with open(r'.\jsons\{0}'.format(json_f)) as json_file:
                data = json.load(json_file)
                if len(data) != 0:
                    for elem in data:
                        #print(elem['id'])
                        dov_numb = elem['id']
                        if f'http://{CRYPTOSRVIP}:96/idp/rest/getview/{dov_numb}' not in DovsUrl:
                            #print(f'http://{CRYPTOSRVIP}:96/idp/rest/getview/{dov_numb}'.split('/'))
                            if pathlib.Path(r".\jsons\dovydka_{0}.json".format(f'http://{CRYPTOSRVIP}:96/idp/rest/getview/{dov_numb}'.split('/')[6])).exists():
                                print(r".\jsons\dovydka_{0}.json".format(f'http://{CRYPTOSRVIP}:96/idp/rest/getview/{dov_numb}'.split('/')[6]))
                                
                            else:
                                DovsUrl.append(f'http://{CRYPTOSRVIP}:96/idp/rest/getview/{dov_numb}')
    print(len(DovsUrl))
    asyncio.run(main2(CRYPTOSRVIP, USERNAME, USERPASSWORD, DovsUrl))
    
    
    '''
        raise asyncio.TimeoutError from None
asyncio.exceptions.TimeoutError
    '''
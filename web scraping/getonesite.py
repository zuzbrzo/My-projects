import pandas as pd
from parsel import Selector
import time
from bs4 import BeautifulSoup
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By


def getonesite(driver, url):
    driver.get(url)
    time.sleep(3)
    result = {'url': [], 'job title': [], 'address': [], 'remote': [], 'salary': [], 'pay': [], 'contract': [],
              'company': [], 'exp lvl': [], 'company size': [], 'tech stack': [], 'description': []}

    if_button = True
    try:
        driver.find_element(By.CLASS_NAME, 'css-15wb2o1').click()
    except NoSuchElementException:
        if_button = False

    sel = Selector(text=driver.page_source)
    rep = 1

    # salary & pay & contract
    for item in sel.xpath("//div[contains(@class, 'css-1wla3xl')]"):
        sal = item.css(".css-a2pcn2::text").get()
        result['salary'].append(sal.strip("\xa0"))
        pay = item.css(".css-rmoont::text").get()
        if pay is None:
            result['pay'].append("-")
        else:
            result['pay'].append(pay.strip("\xa0"))
        con = item.css(".css-qy8eaj::text").get()
        result['contract'].append(con.strip("- "))

    if len(result['salary']) > 1:
        rep = len(result['salary'])

    # job title & remote
    for item in sel.xpath("//div[contains(@class,'css-1ex2t5a')]"):
        jt = item.css('.css-1id4k1::text')
        for _ in range(rep):
            result['job title'].append(jt.get())
        rem = item.xpath("//div[contains(@class, '1f4p1d3')]//span[contains(@class,'css-ioglek')]/text()")
        if rem.get() is None:
            rem = item.xpath("//div[contains(@class, '1f4p1d3')]//span[contains(@class,'css-13p5d07')]/text()")
        for _ in range(rep):
            result['remote'].append(rem.get())

    # address
    address = []
    if if_button:
        address = []
        for item in sel.xpath("//div[contains(@class,'css-1ex2t5a')]"):
            adr = item.xpath(
                "//div[contains(@class, '1f4p1d3')]//span[contains(@class,'css-9wmrp4')]//button[contains(@class, 'css-15wb2o1')]//span/text()")
            address.append(adr.get().split()[0].strip(","))
        for item in sel.xpath("//div[contains(@class,'css-70qvj9')]//span/text()"):
            address.append(item.get().split()[0].strip(","))
    else:
        for item in sel.xpath("//div[contains(@class,'css-1ex2t5a')]"):
            adr = item.xpath("//div[contains(@class, '1f4p1d3')]//span[contains(@class,'css-9wmrp4')]//span/text()")
            address = adr.getall()[1]
    for _ in range(rep):
        result['address'].append(address)

    # company & company size & exp lvl
    for item in sel.xpath("//div[contains(@class, 'css-1uvpahd')]"):
        comp = item.css(".css-l4opor::text")
        subtitle = item.css(".css-eytwkb::text").get()
        if subtitle == 'Company name':
            for _ in range(rep):
                result['company'].append(comp.get())
        title = item.css(".css-1ji7bvd::text").get()
        if subtitle == 'Company size':
            for _ in range(rep):
                result['company size'].append(title)
        elif subtitle == 'EXP. lvl':
            for _ in range(rep):
                result['exp lvl'].append(title)

    tech_dict = {}
    for item in sel.xpath("//div[contains(@class, 'css-1xm32e0')]"):
        technology = item.css('.css-1eroaug::text').get()
        level = item.css('.css-19mz16e::text').get()
        tech_dict[technology] = level
    for _ in range(rep):
        result['tech stack'].append(tech_dict)

    description = ""
    for item in sel.xpath("//div[contains(@class, 'css-p1hlmi')]//div"):
        for element in item.getall():
            description += element
    cleantext = BeautifulSoup(description, "lxml").text
    for _ in range(rep):
        result['description'].append(cleantext)

    for _ in range(rep):
        result['url'].append(url)

    return pd.DataFrame(result)

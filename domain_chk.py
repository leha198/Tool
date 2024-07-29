#!/usr/bin/env python3
import requests
import subprocess
import dns.resolver
import pandas as pd

def check_vn_whois(domain):
    url = f"https://whois.inet.vn/api/whois/domainspecify/{domain}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        return data.get('registrar', None)
    else:
        return None

def extract_registrar(whois_output):
    for line in whois_output.splitlines():
        if line.strip().lower().startswith("registrar:"):
            return line.strip().split(":", 1)[1].strip()
    return None

def check_other_whois(domain):
    try:
        process = subprocess.Popen(['whois', domain], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        stdout, stderr = process.communicate()
        if process.returncode == 0:
            return extract_registrar(stdout)
        else:
            return None
    except Exception as e:
        return None

def get_dns_info(domain):
    try:
        ns_records = dns.resolver.resolve(domain, 'NS')
        nameserver = ns_records[0].target.to_text() if ns_records else None
        a_records = dns.resolver.resolve(domain, 'A')
        a_address = a_records[0].address if a_records else None
        return a_address, nameserver
    except Exception as e:
        return None, None

data = []

with open('domains.txt') as file:
    for line in file:
        domain = line.strip()
        if domain.endswith('.vn'):
            registrar = check_vn_whois(domain)
        else:
            registrar = check_other_whois(domain)
        ip, ns = get_dns_info(domain)
        data.append([domain, ip if ip else '', ns if ns else '', registrar if registrar else ''])

df = pd.DataFrame(data, columns=['Domain', 'IP', 'Nameserver', 'Registrar'])
df.to_excel('domain_info.xlsx', index=False, engine='openpyxl')

print("Download file domain_info.xlsx")

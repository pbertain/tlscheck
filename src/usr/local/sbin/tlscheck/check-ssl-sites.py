"""
Gathers band conditions and solar data to auto-generate an updated webpage with the data
"""
import datetime
import pytz
import requests
import textwrap
import time
import xmltodict

USER_AGENT = 'HamPuff/14.074'
HP_URL = 'http://www.hamqsl.com/solarxml.php'
HP_HDRS = {'User-Agent' : USER_AGENT}
HP_REQ = requests.get(HP_URL, params=HP_HDRS)
HP_RES = HP_REQ.text
MY_DICT = xmltodict.parse(HP_RES)
MY_10m_BAND = '12m-10m' # 3,7
MY_15m_BAND = '17m-15m' # 2,6
MY_20m_BAND = '30m-20m' # 1,5
MY_40m_BAND = '80m-40m' # 0,4
MY_BANDS = {MY_10m_BAND, MY_15m_BAND, MY_20m_BAND, MY_40m_BAND}
HAMQSL_UPDATE = MY_DICT['solar']['solardata']['updated']
SOLARFLUX = MY_DICT['solar']['solardata']['solarflux']
A_INDEX = MY_DICT['solar']['solardata']['aindex']
K_INDEX = MY_DICT['solar']['solardata']['kindex']
SUNSPOTS = MY_DICT['solar']['solardata']['sunspots']
PAC = pytz.timezone('US/Pacific')
EAS = pytz.timezone('US/Eastern')
UTC = pytz.timezone("UTC")
FULL_FMT = '%a %m/%d %H:%M %Z'
TIME_FMT = '%H:%M %Z'
PAC_CUR_TIME      = datetime.datetime.now(PAC).strftime(FULL_FMT)
EAS_CUR_TIME      = datetime.datetime.now(EAS).strftime(FULL_FMT)
UTC_CUR_TIME      = datetime.datetime.now(UTC).strftime(FULL_FMT)

if int(SOLARFLUX) < 100:
    SOLARFLUX_CLASS = "band_cond_poor_std"
elif 100 <= int(SOLARFLUX) < 150:
    SOLARFLUX_CLASS = "band_cond_fair_std"
elif 150 <= int(SOLARFLUX):
    SOLARFLUX_CLASS = "band_cond_good_std"
else:
    SOLARFLUX_CLASS = "band_cond_unkn_std"

if int(K_INDEX) > 4:
    K_INDEX_CLASS = "band_cond_poor_std"
elif 2 < int(K_INDEX) <= 4:
    K_INDEX_CLASS = "band_cond_fair_std"
elif int(K_INDEX) < 3:
    K_INDEX_CLASS = "band_cond_good_std"
else:
    K_INDEX_CLASS = "band_cond_unkn_std"

print(textwrap.dedent("""\
    <html>
        <title>HamPuff - Amateur Radio Info</title>

        <head>
            <meta http-equiv="refresh" content="300">
            <link rel="stylesheet" type="text/css" href="/css/main.css">
        </head>

        <body bgcolor="#333333" link="#FFA500" alink="#FFA500" vlink="#FFA500">
            <table class="table">
                <tr>
                    <td class="td_titles" colspan="4" vertical-align="center"><a href="https://hampuff.com/"><img width="200" height="74" src="/images/hampuff-logo.png"></a></td>
                </tr>
                <tr>
                    <td class="td_titles" colspan="4" vertical-align="center"><center>Solar Conditions</center></td>
                </tr>
                <tr class="th">
                    <th>Solar Flux Index (SFI)</th>
                    <th>A-Index</th>
                    <th>K-Index</th>
                    <th>Sunspot Number</th>
                </tr>
                <tr class="td">
                    <td class=%s>%s</td>
                    <td>%s</td>
                    <td class=%s>%s</td>
                    <td>%s</td>
                </tr>
                <tr>
                    <td class="td_titles" colspan="4" vertical-align="center"><center>Band Conditions</center></td>
                </tr>
                <tr class="th">
                    <th colspan="2">BAND</th>
                    <th>DAY</th>
                    <th>NIGHT</th>
                </tr>
""") % (SOLARFLUX_CLASS, SOLARFLUX, A_INDEX, K_INDEX_CLASS, K_INDEX, SUNSPOTS))

for i in sorted(MY_BANDS, reverse=True):
    if i == '12m-10m': # 3,7
        DAY_CONDITIONS = MY_DICT['solar']['solardata']['calculatedconditions']['band'][3]['#text']
        NIGHT_CONDITIONS = MY_DICT['solar']['solardata']['calculatedconditions']['band'][7]['#text']
    elif i == '17m-15m': # 2,6
        DAY_CONDITIONS = MY_DICT['solar']['solardata']['calculatedconditions']['band'][2]['#text']
        NIGHT_CONDITIONS = MY_DICT['solar']['solardata']['calculatedconditions']['band'][6]['#text']
    elif i == '30m-20m': # 1,5
        DAY_CONDITIONS = MY_DICT['solar']['solardata']['calculatedconditions']['band'][1]['#text']
        NIGHT_CONDITIONS = MY_DICT['solar']['solardata']['calculatedconditions']['band'][5]['#text']
    elif i == '80m-40m': # 0,4
        DAY_CONDITIONS = MY_DICT['solar']['solardata']['calculatedconditions']['band'][0]['#text']
        NIGHT_CONDITIONS = MY_DICT['solar']['solardata']['calculatedconditions']['band'][4]['#text']
    else:
        DAY_CONDITIONS = 'NA'
        NIGHT_CONDITIONS = 'NA'
    if DAY_CONDITIONS == 'Poor':
        DAY_COND_LAYER_CLASS = "band_cond_poor_std"
    elif DAY_CONDITIONS == 'Fair':
        DAY_COND_LAYER_CLASS = "band_cond_fair_std"
    elif DAY_CONDITIONS == 'Good':
        DAY_COND_LAYER_CLASS = "band_cond_good_std"
    else:
        DAY_COND_LAYER_CLASS = "band_cond_unkn_std"
    if NIGHT_CONDITIONS == 'Poor':
        NIGHT_COND_LAYER_CLASS = "band_cond_poor_std"
    elif NIGHT_CONDITIONS == 'Fair':
        NIGHT_COND_LAYER_CLASS = "band_cond_fair_std"
    elif NIGHT_CONDITIONS == 'Good':
        NIGHT_COND_LAYER_CLASS = "band_cond_good_std"
    else:
        NIGHT_COND_LAYER_CLASS = "band_cond_unkn_std"
    print(textwrap.dedent("""\
                <tr class="td">
                    <td class="band_cond_unkn_std" colspan="2">%s</td>
                    <td class="%s">%s</td>
                    <td class="%s">%s</td>
                </tr>
    """) % (i, DAY_COND_LAYER_CLASS, DAY_CONDITIONS, NIGHT_COND_LAYER_CLASS, NIGHT_CONDITIONS))

print(textwrap.dedent("""\
                <tr>
                    <td class="td_titles" vertical-align="center">HamQSL update time:</td>
                    <td class="td_lg" colspan="3" vertical-align="center"><center>%s</center></td>
                </tr>
                <tr>
                    <td class="td_titles" rowspan="3" vertical-align="center">HamPuff update time:</td>
                    <td class="td_cfb" colspan="3" vertical-align="center"><center>%s</center></td>
                </tr>
                <tr>
                    <td class="td_lg" colspan="3" vertical-align="center"><center>%s</center></td>
                </tr>
                <tr>
                    <td class="td_cfb" colspan="3" vertical-align="center"><center>%s</center></td>
                </tr>
                <tr>
                    <td class="footer" colspan="4"><a href="http://www.hamqsl.com/solarxml.php">XML Data provided by HamQSL</td>
                </tr>
            </table>
        </body>
    </html>
 """) % (HAMQSL_UPDATE, UTC_CUR_TIME, PAC_CUR_TIME, EAS_CUR_TIME))


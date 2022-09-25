#!/bin/sh

# check-ssl-sites.sh
# Checks the SSL expiration of Bertain CDN sites to generate the web pages
# Paul Bertain paul@bertain.net
# Mon 16 Aug 2021

##### CUSTOMIZE HERE #####
##### END CUSTOMIZATION SECTION #####

/bin/logger "TLSCheck run starting at `date`."

FILEPATH="/var/www/vhosts/brtn.cloud/gencon/"
PRODFILE="${FILEPATH}/tlscheck.html"
TEMPFILE="${PRODFILE}.temp"

cat /dev/null > ${TEMPFILE}

ORIGINHOSTS="brtn.cloud cacti.bertain.net choreminder.bertain.net march-madness.bertain.net skye.bertain.net"
CDNHOSTS="airpuff.info amateur-ham-rad.io berta.in bertain.net coronapuff.net hampuff.com haydad.group jtfm.news km6ajq.net lipaamdesogeskhali.us n538cd.tech reflectionsofcommunity.org sector-2814.net thechailife.store unix-chix.org"
DNSADMIN="dnsadmin01.brtn.cloud dnsadmin02.brtn.cloud"
ALLHOSTS="${ORIGINHOSTS} ${CDNHOSTS} ${DNSADMIN}"

echo "<html>" > ${TEMPFILE}
echo "	<title>Bertain CDN TLS Status</title>" >> ${TEMPFILE}
echo "" >> ${TEMPFILE}
echo "	<head>" >> ${TEMPFILE}
echo "		<meta http-equiv=\"refresh\" content=\"300\">" >> ${TEMPFILE}
echo "		<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/main.css\">" >> ${TEMPFILE}
echo "	</head>" >> ${TEMPFILE}
echo "" >> ${TEMPFILE}
echo "	<body bgcolor=\"#333333\" link=\"#FFA500\" alink=\"#FFA500\" vlink=\"#FFA500\">" >> ${TEMPFILE}
echo "		<table class=\"table\">" >> ${TEMPFILE}
echo "			<tr>" >> ${TEMPFILE}
echo "				<td class=\"td_titles\" colspan=\"2\" vertical-align=\"center\"><a href=\"https://brtn.cloud/\"><img width=\"200\" height=\"200\" src=\"/img/tls-meme-1.jpg\"></a></td>" >> ${TEMPFILE}
echo "			</tr>" >> ${TEMPFILE}
echo "			<tr>" >> ${TEMPFILE}
echo "              <td class=\"td_titles\" colspan=\"2\" vertical-align=\"center\"><center>TLS Monitor</center></td>" >> ${TEMPFILE}
echo "			</tr>" >> ${TEMPFILE}

########################
##    Origin Hosts    ##
########################

echo "      <tr class=\"th\">" >> ${TEMPFILE}
echo "              <th>Origin</th>" >> ${TEMPFILE}
echo "              <th>Expiration Date</th>" >> ${TEMPFILE}
echo "                      </tr>" >> ${TEMPFILE}

for HOST in ${ALLHOSTS} ; do
    EXPIREDATE=`echo | openssl s_client -servername ${HOST} -connect 73.2.35.16:443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
    echo "          <tr class=\"td\">" >> ${TEMPFILE}
    echo "              <td class=\"td\">${HOST}</td>" >> ${TEMPFILE}
    echo "              <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
    EXPIREDATE=""
    echo "			</tr>" >> ${TEMPFILE}
done

#########################
##    IOLAX01 Hosts    ##
#########################

echo "      <tr class=\"th\">" >> ${TEMPFILE}
echo "              <th>IOLAX01</th>" >> ${TEMPFILE}
echo "              <th>Expiration Date</th>" >> ${TEMPFILE}
echo "                      </tr>" >> ${TEMPFILE}

for HOST in ${CDNHOSTS} ; do
	WWWHOST="www.${HOST}"
	EXPIREDATE=`echo | openssl s_client -servername ${WWWHOST} -connect iolax01.infra.brtn.cloud:443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
	echo "            <tr class=\"td\">" >> ${TEMPFILE}
	echo "              <td class=\"td\">${WWWHOST}</td>" >> ${TEMPFILE}
	echo "              <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
	EXPIREDATE=""
	echo "            </tr>" >> ${TEMPFILE}
done

#########################
##    IOLAX02 Hosts    ##
#########################

echo "      <tr class=\"th\">" >> ${TEMPFILE}
echo "              <th>IOLAX02</th>" >> ${TEMPFILE}
echo "              <th>Expiration Date</th>" >> ${TEMPFILE}
echo "                      </tr>" >> ${TEMPFILE}

for HOST in ${CDNHOSTS} ; do
	WWWHOST="www.${HOST}"
	EXPIREDATE=`echo | openssl s_client -servername ${WWWHOST} -connect iolax02.infra.brtn.cloud:443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
	echo "          <tr class=\"td\">" >> ${TEMPFILE}
	echo "              <td class=\"td\">${WWWHOST}</td>" >> ${TEMPFILE}
	echo "              <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
	EXPIREDATE=""
	echo "			</tr>" >> ${TEMPFILE}
done


echo "          </tr>" >> ${TEMPFILE}
echo "          <tr>" >> ${TEMPFILE}
echo "              <td class=\"td_titles\" vertical-align=\"center\">Check time:</td>" >> ${TEMPFILE}
echo "              <td class=\"th\" colspan=\"1\" vertical-align=\"center\"><center>`date`</center></td>" >> ${TEMPFILE}
echo "          </tr>" >> ${TEMPFILE}
echo "          <tr>" >> ${TEMPFILE}
echo "              <td class=\"footer\" colspan=\"2\"><a href="http://brtn.cloud/">TLS Data is provided per server.</td>" >> ${TEMPFILE}
echo "          </tr>" >> ${TEMPFILE}
echo "        </table>" >> ${TEMPFILE}
echo "    </body>" >> ${TEMPFILE}
echo "</html>" >> ${TEMPFILE}

mv ${TEMPFILE} ${PRODFILE}

/bin/logger "TLSCheck run complete at `date`"



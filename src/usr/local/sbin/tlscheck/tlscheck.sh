#!/bin/sh

# check-ssl-sites.sh
# Checks the SSL expiration of Bertain CDN sites to generate the web pages
# Paul Bertain paul@bertain.net
# Mon 16 Aug 2021

##### CUSTOMIZE HERE #####
##### END CUSTOMIZATION SECTION #####

/bin/logger "TLSCheck run starting at `date`."

FILEPATH="/var/www/vhosts/brtn.cloud/gencon/"
HTMLPATH="/var/www/vhosts/brtn.cloud/html/"
PRODFILE="${FILEPATH}/tlscheck.html"
HTMLFILE="${HTMLPATH}/tlscheck.html"
TEMPFILE="${PRODFILE}.temp"

cat /dev/null > ${TEMPFILE}

# Raw Lists
CDNHOSTS="airpuff.info amateur-ham-rad.io berta.in bertain.net brtn.cloud burl.link hampuff.com haydad.group jtfm.news km6ajq.net lipaamdesogeskhali.us march-madness.bertain.net n538cd.aero reflectionsofcommunity.org sector-2814.net thechailife.store unix-chix.org"
DNSADMIN="dnsadmin01.brtn.cloud dnsadmin02.brtn.cloud"
#HAPROXYVIP="haproxy.bertain.net"
#NETSCALERVIP="pbb07.infra.brtn.cloud"
NIRDCLUB="km6ajq.net nird.club philandamy.org th3b3a7l.es"
#NGINXVIP="pbb08.infra.brtn.cloud"
ORIGINHOSTS="skye.bertain.net"
MATTS808="808.org"

# Dynamic Lists
ALLHOSTS="${ORIGINHOSTS} ${CDNHOSTS}"

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
echo "				<td class=\"td_titles\" colspan=\"3\" vertical-align=\"center\"><a href=\"https://brtn.cloud/\"><img width=\"100\" height=\"100\" src=\"/img/tls-meme-1.jpg\"></a></td>" >> ${TEMPFILE}
echo "			</tr>" >> ${TEMPFILE}
echo "			<tr>" >> ${TEMPFILE}
echo "              <td class=\"td_titles\" colspan=\"3\" vertical-align=\"center\"><center>TLS Monitor</center></td>" >> ${TEMPFILE}
echo "			</tr>" >> ${TEMPFILE}

########################
##    Origin Hosts    ##
########################

echo "                      <tr class=\"th\">" >> ${TEMPFILE}
echo "                          <th>Origin</th>" >> ${TEMPFILE}
echo "                          <th>Expiration Date</th>" >> ${TEMPFILE}
echo "                          <th>Provider</th>" >> ${TEMPFILE}
echo "                          <th>Host IP</th>" >> ${TEMPFILE}
echo "                      </tr>" >> ${TEMPFILE}

for HOST in ${ALLHOSTS} ; do
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
    EXPIREDATE=`echo | openssl s_client -servername ${HOST} -connect 192.168.3.91:443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
    PROVIDER=`echo | openssl s_client -servername ${HOST} -connect 192.168.3.91:443 2>/dev/null | openssl x509 -noout -dates -issuer | awk -F= '{ print $4 }' | awk -F, '{ print $1 }' | sed -e's/^ //g'`
    HOST_IP=`dig +short ${HOST}`
    echo "          <tr class=\"td\">" >> ${TEMPFILE}
    echo "              <td class=\"td\">${HOST}</td>" >> ${TEMPFILE}
    echo "              <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
    echo "              <td class=\"td\">${PROVIDER}</td>" >> ${TEMPFILE}
    echo "              <td class=\"td_ctr\">${HOST_IP}</td>" >> ${TEMPFILE}
    echo "			</tr>" >> ${TEMPFILE}
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
done

########################
##   DNS Admin Hosts  ##
########################

echo "                      <tr class=\"th\">" >> ${TEMPFILE}
echo "                          <th>DNS Admin Hosts</th>" >> ${TEMPFILE}
echo "                          <th>Expiration Date</th>" >> ${TEMPFILE}
echo "                          <th>Provider</th>" >> ${TEMPFILE}
echo "                          <th>Host IP</th>" >> ${TEMPFILE}
echo "                      </tr>" >> ${TEMPFILE}

for HOST in ${DNSADMIN} ; do
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
    EXPIREDATE=`echo | openssl s_client -servername ${HOST} -connect ${HOST}:8443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
    PROVIDER=`echo | openssl s_client -servername ${HOST} -connect ${HOST}:8443 2>/dev/null | openssl x509 -noout -dates -issuer | awk -F= '{ print $4 }' | awk -F, '{ print $1 }' | sed -e's/^ //g'`
    HOST_IP=`dig +short ${HOST}`
    echo "          <tr class=\"td\">" >> ${TEMPFILE}
    echo "       <td class=\"td\">${HOST}</td>" >> ${TEMPFILE}
    echo "       <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
    echo "       <td class=\"td\">${PROVIDER}</td>" >> ${TEMPFILE}
    echo "       <td class=\"td_ctr\">${HOST_IP}</td>" >> ${TEMPFILE}
    echo "                      </tr>" >> ${TEMPFILE}
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
done

########################
##      Nird Club     ##
########################

echo "      <tr class=\"th\">" >> ${TEMPFILE}
echo "           <th>Nird Club</th>" >> ${TEMPFILE}
echo "           <th>Expiration Date</th>" >> ${TEMPFILE}
echo "           <th>Provider</th>" >> ${TEMPFILE} 
echo "           <th>Host IP</th>" >> ${TEMPFILE} 
echo "      </tr>" >> ${TEMPFILE}

for HOST in ${NIRDCLUB} ; do
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
    EXPIREDATE=`echo | openssl s_client -servername ${HOST} -connect ${HOST}:443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
    PROVIDER=`echo | openssl s_client -servername ${HOST} -connect ${HOST}:443 2>/dev/null | openssl x509 -noout -dates -issuer | awk -F= '{ print $4 }' | awk -F, '{ print $1 }' | sed -e's/^ //g' | tr '\n' ' '`
    HOST_IP=`dig +short ${HOST}`
    echo "                      <tr class=\"td\">" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${HOST}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${PROVIDER}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td_ctr\">${HOST_IP}</td>" >> ${TEMPFILE}
    echo "                      </tr>" >> ${TEMPFILE}
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
done

########################
##     Matt's 808     ##
########################

echo "      <tr class=\"th\">" >> ${TEMPFILE}
echo "           <th>Matt's 808</th>" >> ${TEMPFILE}
echo "           <th>Expiration Date</th>" >> ${TEMPFILE}
echo "           <th>Provider</th>" >> ${TEMPFILE} 
echo "           <th>Host IP</th>" >> ${TEMPFILE} 
echo "      </tr>" >> ${TEMPFILE}

for HOST in ${MATTS808} ; do
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
    EXPIREDATE=`echo | openssl s_client -servername ${HOST} -connect ${HOST}:443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
    PROVIDER=`echo | openssl s_client -servername ${HOST} -connect ${HOST}:443 2>/dev/null | openssl x509 -noout -dates -issuer | awk -F= '{ print $4 }' | awk -F, '{ print $1 }' | sed -e's/^ //g' | tr '\n' ' '`
    HOST_IP=`dig +short ${HOST}`
    echo "                      <tr class=\"td\">" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${HOST}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${PROVIDER}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td_ctr\">${HOST_IP}</td>" >> ${TEMPFILE}
    echo "                      </tr>" >> ${TEMPFILE}
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
done

#########################
##    IOLAX01 Hosts    ##
#########################

echo "      <tr class=\"th\">" >> ${TEMPFILE}
echo "          <th>IOLAX01</th>" >> ${TEMPFILE}
echo "          <th>Expiration Date</th>" >> ${TEMPFILE}
echo "          <th>Provider</th>" >> ${TEMPFILE} 
echo "          <th>Host IP</th>" >> ${TEMPFILE} 
echo "      </tr>" >> ${TEMPFILE}

for HOST in ${CDNHOSTS} ; do
    WWWHOST="www.${HOST}"
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
    EXPIREDATE=`echo | openssl s_client -servername ${WWWHOST} -connect iolax01.infra.brtn.cloud:443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
    PROVIDER=`echo | openssl s_client -servername ${WWWHOST} -connect iolax01.infra.brtn.cloud:443 2>/dev/null | openssl x509 -noout -dates -issuer | awk -F= '{ print $4 }' | awk -F, '{ print $1 }' | sed -e's/^ //g'`
    HOST_IP=`dig +short ${HOST}`
    echo "                      <tr class=\"td\">" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${WWWHOST}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${PROVIDER}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td_ctr\">${HOST_IP}</td>" >> ${TEMPFILE}
    echo "                      </tr>" >> ${TEMPFILE}
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
done

#########################
##    IOLAX02 Hosts    ##
#########################

echo "      <tr class=\"th\">" >> ${TEMPFILE}
echo "          <th>IOLAX02</th>" >> ${TEMPFILE}
echo "          <th>Expiration Date</th>" >> ${TEMPFILE}
echo "          <th>Provider</th>" >> ${TEMPFILE} 
echo "          <th>Host IP</th>" >> ${TEMPFILE} 
echo "      </tr>" >> ${TEMPFILE}

for HOST in ${CDNHOSTS} ; do
    if [ "${HOST}" = "march-madness.bertain.net" ]; then
        WWWHOST="march-madness.bertain.net"
    else
        WWWHOST="www.${HOST}"
    fi
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
    EXPIREDATE=`echo | openssl s_client -servername ${WWWHOST} -connect iolax02.infra.brtn.cloud:443 2>/dev/null | openssl x509 -noout -dates | grep After | awk -F= '{ print $2 }' | awk '{ print $1 "-" $2 "-" $4 "-" $3 }'`
    PROVIDER=`echo | openssl s_client -servername ${WWWHOST} -connect iolax02.infra.brtn.cloud:443 2>/dev/null | openssl x509 -noout -dates -issuer | awk -F= '{ print $4 }' | awk -F, '{ print $1 }' | sed -e's/^ //g'`
    HOST_IP=`dig +short ${HOST}`
    echo "                      <tr class=\"td\">" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${WWWHOST}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${EXPIREDATE}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td\">${PROVIDER}</td>" >> ${TEMPFILE}
    echo "                          <td class=\"td_ctr\">${HOST_IP}</td>" >> ${TEMPFILE}
    echo "                      </tr>" >> ${TEMPFILE}
    EXPIREDATE=""
    PROVIDER=""
    HOST_IP=""
done


echo "          </tr>" >> ${TEMPFILE}
echo "          <tr>" >> ${TEMPFILE}
echo "              <td class=\"td_titles\" vertical-align=\"center\">Check time:</td>" >> ${TEMPFILE}
echo "              <td class=\"th\" colspan=\"1\" vertical-align=\"center\"><center>`date`</center></td>" >> ${TEMPFILE}
echo "          </tr>" >> ${TEMPFILE}
echo "          <tr>" >> ${TEMPFILE}
echo "              <td class=\"footer\" colspan=\"3\"><a href="http://brtn.cloud/">TLS Data is provided per server.</td>" >> ${TEMPFILE}
echo "          </tr>" >> ${TEMPFILE}
echo "        </table>" >> ${TEMPFILE}
echo "    </body>" >> ${TEMPFILE}
echo "</html>" >> ${TEMPFILE}

mv ${TEMPFILE} ${PRODFILE}
chown nginx:nginx ${PRODFILE}
cp ${PRODFILE} ${HTMLFILE}
chown nginx:nginx ${HTMLFILE}

/bin/logger "TLSCheck run complete at `date`"


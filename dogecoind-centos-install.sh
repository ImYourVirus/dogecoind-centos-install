echo " Updating Server "
yum -y update

echo " Step #1: Installing the Dependencies "
yum -y groupinstall "Development Tools"
yum -y install zlib-devel bzip2-devel wget python-devel
echo '/usr/local/lib' > /etc/ld.so.conf.d/usr_local_lib.conf && /sbin/ldconfig
echo '/usr/local/lib64' > /etc/ld.so.conf.d/usr_local_lib64.conf && /sbin/ldconfig

echo " Step #2: Installing OpenSSL "
cd /usr/local/src
wget -qO- http://www.openssl.org/source/openssl-1.0.1f.tar.gz | tar xzv
cd openssl-1.0.1f
./config shared --prefix=/usr/local --openssldir=/usr/local/ssl
make && make install

echo " Step #3: Installing Boost (A Collection of C++ Libraries) "
cd /usr/local/src
wget -qO- http://downloads.sourceforge.net/boost/boost_1_55_0.tar.bz2 | tar xjv
cd boost_1_55_0/
./bootstrap.sh --prefix=/usr/local
./b2 install --with=all

echo " Step #4: Installing BerkeleyDB (A Library for High-Performance Database Functionality) "
cd /usr/local/src
wget -qO- http://download.oracle.com/berkeley-db/db-5.1.19.tar.gz | tar xzv
cd db-5.1.19/build_unix
../dist/configure --prefix=/usr/local --enable-cxx
make && make install

echo "Step #Wow: Installing dogecoind "
cd /usr/local/src
ldconfig
mkdir /usr/local/src/dogecoin-master
cd /usr/local/src/dogecoin-master
wget -qO- https://github.com/dogecoin/dogecoin/archive/master-1.6.tar.gz --no-check-certificate | tar xzv --strip-components 1
cd src
make -f makefile.unix USE_UPNP=- BDB_LIB_PATH=/usr/local/lib OPENSSL_LIB_PATH=/usr/local/lib64

echo " The dogecoind binary should now be compiled. Next we.ll strip the debugging symbols out of the binary and move it to a location that allows for easy execution. "
strip dogecoind
cp -a dogecoind /usr/local/bin/

echo " Step #6: Configuring dogecoind "
echo " Most scrypt-based cryptocurrencies use a configuration file that is nearly identical to LiteCoin.s. It is generally safe to use Litecoin documentation when looking up configuration variables. "
echo " If you do not have a standard non-root user, then you can create one using the useradd command. In this example we.re going to create a user named doge. "
useradd -m -s/bin/bash doge

cd /home/doge/.dogecoin
pass=$(tr -dc A-Za-z0-9 </dev/urandom |  head -c 30)
echo "rpcuser=dogecoinrpc\n
rpcpassword=$pass" >> dogecoin.conf

echo " Assume the identity of the non-privileged user, doge. "
su - doge

echo " Now that you.ve assumed the identity of a non-privileged user, you will want to run dogecoind for the first time. "
dogecoind
#wget https://raw.github.com/dogecoin/dogecoin/master-1.6/release/dogecoin.conf


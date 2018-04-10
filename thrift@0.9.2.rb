class ThriftAT092 < Formula
    desc "Framework for scalable cross-language services development"
    homepage "https://thrift.apache.org"
    url "https://archive.apache.org/dist/thrift/0.9.2/thrift-0.9.2.tar.gz"
    sha256 "cef50d3934c41db5fa7724440cc6f10a732e7a77fe979b98c23ce45725349570"
  
    bottle do
      cellar :any
    end
  
    keg_only :versioned_formula
  
    option "without-haskell", "Install Haskell binding"
    option "without-erlang", "Install Erlang binding"
    option "with-java", "Install Java binding"
    option "without-perl", "Install Perl binding"
    option "without-php", "Install Php binding"
  
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "bison" => :build
    depends_on "libtool" => :build
    depends_on "pkg-config" => :build
    depends_on "boost"
    depends_on "openssl"
    depends_on "python" => :optional
  
    if build.with? "java"
      depends_on "ant" => :build
      depends_on :java => "1.8"
    end
  
    def install
      args = ["--without-ruby", "--without-tests", "--without-php_extension"]
  
      args << "--without-python" if build.without? "python"
      args << "--without-haskell" if build.without? "haskell"
      args << "--without-java" if build.without? "java"
      args << "--without-perl" if build.without? "perl"
      args << "--without-php" if build.without? "php"
      args << "--without-erlang" if build.without? "erlang"
  
      ENV.cxx11 if MacOS.version >= :mavericks && ENV.compiler == :clang
  
      # Don't install extensions to /usr
      ENV["PY_PREFIX"] = prefix
      ENV["PHP_PREFIX"] = prefix
      ENV["JAVA_PREFIX"] = pkgshare/"java"
  
      # configure's version check breaks on ant >1.10 so just override it. This
      # doesn't need guarding because of the --without-java flag used above.
      inreplace "configure", 'ANT=""', "ANT=\"#{Formula["ant"].opt_bin}/ant\""
  
      system "./configure", "--disable-debug",
                            "--prefix=#{prefix}",
                            "--libdir=#{lib}",
                            *args
      ENV.deparallelize
      system "make", "install"
    end
  
    test do
      assert_match "Thrift", shell_output("#{bin}/thrift --version")
    end
  end
  
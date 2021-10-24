FROM clojure
COPY . /consize/
WORKDIR /consize/src
ENTRYPOINT ["clj", "-M", "consize.clj", "\\ prelude-plain.txt run say-hi"]

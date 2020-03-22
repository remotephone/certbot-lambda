FROM amazonlinux:2.0.20200207.1

COPY entrypoint.sh /usr/local/bin/
COPY main.py /tmp/main.py

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]

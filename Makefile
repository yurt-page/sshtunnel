clean:

install:
	mkdir -p ${DESTDIR}/usr/bin/
	cp sshtunnel.sh ${DESTDIR}/usr/bin/sshtunnel
	chmod +x ${DESTDIR}/usr/bin/sshtunnel
	mkdir -p ${DESTDIR}/usr/lib/systemd/user/
	cp sshtunnel.service ${DESTDIR}/usr/lib/systemd/user/
	mkdir -p ${DESTDIR}/root/.ssh/
	cp sshtunnel.config.sh ${DESTDIR}/root/.ssh/
	mkdir -p ${DESTDIR}/usr/share/sshtunnel/
	cp providers_known_hosts ${DESTDIR}/usr/share/sshtunnel/providers_known_hosts

install_all: install reload_service

reload_service:
	systemctl daemon-reload
	systemctl enable sshtunnel
	systemctl restart sshtunnel

uninstall:
	rm -f ${DESTDIR}/usr/bin/sshtunnel
	rm -f ${DESTDIR}/usr/lib/systemd/user/sshtunnel.service
	rm -f ${DESTDIR}/usr/share/sshtunnel/providers_known_hosts

uninstall_all: uninstall
	systemctl stop sshtunnel
	systemctl daemon-reload

restart:
	cp sshtunnel.sh /usr/bin/sshtunnel
	systemctl restart sshtunnel
	systemctl --no-pager -l status sshtunnel
	journalctl -u sshtunnel -f -n 0

stop:
	systemctl stop sshtunnel

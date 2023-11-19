# Jarkom-Modul-3-D17-2023

**Praktikum Jaringan Komputer Modul 3 Tahun 2023**

## Author
| Nama | NRP |Github |
|---------------------------|------------|--------|
|Adam Haidar Azizi | 5025211114 | https://github.com/HADAIZI |
|Ahda Filza Ghaffaru | 5025211144 | https://github.com/Ahdaaa |

# Laporan Resmi
## Daftar Isi
- [Laporan Resmi](#laporan-resmi)
  - [Daftar Isi](#daftar-isi)
  - [Topologi](#topologi)
  - [Config](#config)
- [Soal 1](#Soal-1)
  - [Script](#script)
  - [Result](#result)
- [Soal 2](#Soal-2)
  - [Script](#script-1)
- [Soal 3](#Soal-3)
  - [Script](#script-2)
- [Soal 4](#Soal-4)
  - [Script](#script-3)
  - [Result](#result-1)
- [Soal 5](#Soal-5)
  - [Script](#script-4)
  - [Result](#result-2)
- [Soal 6](#Soal-6)
  - [Script](#script-5)
  - [Result](#result-3)
- [Soal 7](#Soal-7)
  - [Script](#script-6)
  - [Result](#result-4)
- [Soal 8](#Soal-8)
  - [Script](#script-7)
  - [Result](#result-5)
- [Soal 9](#Soal-9)
  - [Script](#script-8)
  - [Result](#result-6)
- [Soal 10](#Soal-10)
  - [Script](#script-9)
  - [Result](#result-7)
- [Soal 11](#Soal-11)
  - [Script](#script-10)
  - [Result](#result-8)
- [Soal 12](#Soal-12)
  - [Script](#script-11)
  - [Result](#result-9)
- [Soal 13](#Soal-13)
  - [Script](#script-12)
  - [Result](#result-10)
- [Soal 14](#Soal-14)
  - [Script](#script-13)
  - [Result](#result-11)
- [Soal 15](#Soal-15)
  - [Script](#script-14)
  - [Result](#result-12)
- [Soal 16](#Soal-16)
  - [Script](#script-15)
  - [Result](#result-13)
- [Soal 17](#Soal-17)
  - [Script](#script-16)
  - [Result](#result-14)
- [Soal 18](#Soal-18)
  - [Script](#script-17)
  - [Result](#result-15)
- [Soal 19](#Soal-19)
  - [Script](#script-18)
  - [Result](#result-16)
- [Soal 20](#Soal-20)
  - [Script](#script-19)
  - [Result](#result-17)

## Topologi
![Alt text](image.png)

## Config
- **Aura (DHCP Relay)**
```
auto eth0
iface eth0 inet dhcp
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.30.0.0/16

auto eth1
iface eth1 inet static
	address 10.30.1.0
	netmask 255.255.255.0

auto eth2
iface eth2 inet static
	address 10.30.2.0
	netmask 255.255.255.0

auto eth3
iface eth3 inet static
	address 10.30.3.0
	netmask 255.255.255.0

auto eth4
iface eth4 inet static
	address 10.30.4.0
	netmask 255.255.255.0
```

- **Himmel (DHCP Server)**
```
auto eth0
iface eth0 inet static
	address 10.30.1.1
	netmask 255.255.255.0
	gateway 10.30.1.0

```

- **Heiter (DNS Server)**
```
auto eth0
iface eth0 inet static
	address 10.30.1.2
	netmask 255.255.255.0
	gateway 10.30.1.0
```
- **Denken (Database Server)**
```
auto eth0
iface eth0 inet dhcp
hwaddress ether 2a:b9:20:f6:fd:c9
```
- **Eisen (Load Balancer)**
```
auto eth0
iface eth0 inet dhcp
hwaddress ether a6:06:02:c2:28:a4
```
- **Frieren (Laravel Worker)**
```
auto eth0
iface eth0 inet dhcp
hwaddress ether 16:8c:a3:19:91:3b
```
- **Flamme (Laravel Worker)**
```
auto eth0
iface eth0 inet dhcp
hwaddress ether 4e:2d:5c:c8:e6:80
```
- **Fern (Laravel Worker)**
```
auto eth0
iface eth0 inet dhcp
hwaddress ether a2:d9:1e:52:fd:ff
```
- **Lawine (PHP Worker)**
```
auto eth0
iface eth0 inet dhcp
hwaddress ether a2:eb:f1:be:9b:65
```
- **Linie (PHP Worker)**
```
auto eth0
iface eth0 inet dhcp
hwaddress ether 36:33:94:64:ef:cc
```
- **Lugner (PHP Worker)**
```
auto eth0
iface eth0 inet dhcp
hwaddress ether a2:9e:52:b8:ec:7c
```
- **Revolte, Richter, Sein, dan Stark (Client)**
```
auto eth0
iface eth0 inet dhcp
```





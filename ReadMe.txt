This file describes how to get set up with this repository.

Prerequisites
-------------

This repository requires another repository of the bitbucket team hullperformance, namely mMySQL.
The MATLAB class cVessel (and all related classes whose names start with cVessel) have a 
	default database connection which requires a cMySQL installation on the local machine.
	In this case, the database connection driver "MySQL ODBC 5.3 ANSI Driver" must be installed.
Hostname: localhost
Port:     3310
Management User: root
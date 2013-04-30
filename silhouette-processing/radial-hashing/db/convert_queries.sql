INSERT INTO dest.images (fasthash, file, 
v000, v001, v002, v003, v004, v005, v006, v007, v008, v009, 
v010, v011, v012, v013, v014, v015, v016, v017, v018, v019, 
v020, v021, v022, v023, v024, v025, v026, v027, v028, v029,
v030, v031) SELECT fasthash, file, 
v000, v001, v002, v003, v004, v005, v006, v007, v008, v009, 
v010, v011, v012, v013, v014, v015, v016, v017, v018, v019, 
v020, v021, v022, v023, v024, v025, v026, v027, v028, v029,
v030, v031 FROM src.images;

CREATE TABLE dest.images (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	fasthash TEXT, 
	file TEXT,
	v000 INT, v001 INT, v002 INT, v003 INT, v004 INT, v005 INT, v006 INT, v007 INT, v008 INT, v009 INT, 
	v010 INT, v011 INT, v012 INT, v013 INT, v014 INT, v015 INT, v016 INT, v017 INT, v018 INT, v019 INT, 
	v020 INT, v021 INT, v022 INT, v023 INT, v024 INT, v025 INT, v026 INT, v027 INT, v028 INT, v029 INT,
	v030 INT, v031);

INSERT INTO dest.images (fasthash, file, 
v000, v001, v002, v003, v004, v005, v006, v007, v008, v009, 
v010, v011, v012, v013, v014, v015, v016, v017, v018, v019, 
v020, v021, v022, v023, v024, v025, v026, v027, v028, v029,
v030, v031) SELECT fasthash, file, 
v000, v001, v002, v003, v004, v005, v006, v007, v008, v009, 
v010, v011, v012, v013, v014, v015, v016, v017, v018, v019, 
v020, v021, v022, v023, v024, v025, v026, v027, v028, v029,
v030, v031 FROM dest.images_tmp;
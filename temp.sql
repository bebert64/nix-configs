--
-- PostgreSQL database dump
--

-- Dumped from database version 13.11 (Debian 13.11-0+deb11u1)
-- Dumped by pg_dump version 13.11 (Debian 13.11-0+deb11u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: archive_status; Type: TYPE; Schema: public; Owner: master
--

CREATE TYPE public.archive_status AS ENUM (
    'to_unzip',
    'to_parse',
    'to_parse_issues',
    'to_complete_issues',
    'to_search_comic_vine_id',
    'ok'
);


ALTER TYPE public.archive_status OWNER TO master;

--
-- Name: diesel_manage_updated_at(regclass); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.diesel_manage_updated_at(_tbl regclass) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format('CREATE TRIGGER set_updated_at BEFORE UPDATE ON %s
                    FOR EACH ROW EXECUTE PROCEDURE diesel_set_updated_at()', _tbl);
END;
$$;


ALTER FUNCTION public.diesel_manage_updated_at(_tbl regclass) OWNER TO master;

--
-- Name: diesel_set_updated_at(); Type: FUNCTION; Schema: public; Owner: master
--

CREATE FUNCTION public.diesel_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (
        NEW IS DISTINCT FROM OLD AND
        NEW.updated_at IS NOT DISTINCT FROM OLD.updated_at
    ) THEN
        NEW.updated_at := current_timestamp;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.diesel_set_updated_at() OWNER TO master;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __diesel_schema_migrations; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.__diesel_schema_migrations (
    version character varying(50) NOT NULL,
    run_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.__diesel_schema_migrations OWNER TO master;

--
-- Name: archives; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.archives (
    id integer NOT NULL,
    path text NOT NULL,
    status public.archive_status NOT NULL
);


ALTER TABLE public.archives OWNER TO master;

--
-- Name: archives_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.archives ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: books; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.books (
    id integer NOT NULL,
    name text,
    CONSTRAINT books_name_check CHECK ((length(name) >= 3))
);


ALTER TABLE public.books OWNER TO master;

--
-- Name: books_additional_files; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.books_additional_files (
    id integer NOT NULL,
    bookd_id integer NOT NULL,
    file_path text NOT NULL,
    CONSTRAINT books_additional_files_file_path_check CHECK ((length(file_path) > 0))
);


ALTER TABLE public.books_additional_files OWNER TO master;

--
-- Name: books_additional_files_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.books_additional_files ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.books_additional_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.books ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: books_issues; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.books_issues (
    id integer NOT NULL,
    bookd_id integer NOT NULL,
    issue_id integer NOT NULL
);


ALTER TABLE public.books_issues OWNER TO master;

--
-- Name: books_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.books_issues ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.books_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: issues; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.issues (
    id integer NOT NULL,
    volume_id integer NOT NULL,
    number integer NOT NULL,
    dir text
);


ALTER TABLE public.issues OWNER TO master;

--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.issues ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: reading_order_elements; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.reading_order_elements (
    id integer NOT NULL,
    issue_id integer,
    book_id integer,
    reading_order_id integer,
    CONSTRAINT reading_order_elements_check CHECK ((num_nonnulls(issue_id, book_id, reading_order_id) = 1))
);


ALTER TABLE public.reading_order_elements OWNER TO master;

--
-- Name: reading_order_elements_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.reading_order_elements ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.reading_order_elements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: reading_orders; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.reading_orders (
    id integer NOT NULL,
    name text,
    CONSTRAINT reading_orders_name_check CHECK ((length(name) >= 3))
);


ALTER TABLE public.reading_orders OWNER TO master;

--
-- Name: reading_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.reading_orders ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.reading_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: volumes; Type: TABLE; Schema: public; Owner: master
--

CREATE TABLE public.volumes (
    id integer NOT NULL,
    name text NOT NULL,
    CONSTRAINT volumes_name_check CHECK ((length(name) >= 3))
);


ALTER TABLE public.volumes OWNER TO master;

--
-- Name: volumes_id_seq; Type: SEQUENCE; Schema: public; Owner: master
--

ALTER TABLE public.volumes ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.volumes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: __diesel_schema_migrations; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.__diesel_schema_migrations (version, run_on) FROM stdin;
00000000000000	2023-07-16 07:56:22.014963
20230715161456	2023-07-16 07:56:22.033868
20230801085151	2023-08-01 08:59:35.717437
\.


--
-- Data for Name: archives; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.archives (id, path, status) FROM stdin;
2	Star Wars/Marvel/501. Age Of Rebellion - Special.zip	to_parse
3	Star Wars/Marvel/424. Star Wars v06 - Out Among The Stars.zip	to_parse
4	Star Wars/Marvel/311. Lando - Double or Nothing.zip	to_parse
5	Star Wars/Marvel/439. Star Wars v13 - Rogues And Rebels.zip	to_parse
6	Star Wars/Marvel/103. Age of The Republic - Count Dooku.zip	to_parse
7	Star Wars/Marvel/701. Captain Phasma.zip	to_parse
8	Star Wars/Marvel/204. Age of The Republic - Special.zip	to_parse
9	Star Wars/Marvel/606. Age of Resistance - General Hux.zip	to_parse
10	Star Wars/Marvel/314. Vader - Dark Visions.zip	to_parse
11	Star Wars/Marvel/410. Darth Vader v01 - Vader.zip	to_parse
12	Star Wars/Marvel/403. Age Of Rebellion - Han Solo.zip	to_parse
13	Star Wars/Marvel/436. Target Vader.zip	to_parse
14	Star Wars/Marvel/550. Age Of Rebellion - Luke Skywalker.zip	to_parse
15	Star Wars/Marvel/205. Age of The Republic - Padme Amidala.zip	to_parse
16	Star Wars/Marvel/607. Age Of Resistance - Kylo Ren.zip	to_parse
17	Star Wars/Marvel/602. The Rise of Kylo Ren.zip	to_parse
18	Star Wars/Marvel/305. Age Of Rebellion - Darth Vader.zip	to_parse
19	Star Wars/Marvel/702. Age Of Resistance - Rey.zip	to_parse
21	Star Wars/Marvel/431. Star Wars v09 - Hope Dies.zip	to_parse
22	Star Wars/Marvel/609. C-3PO.zip	to_parse
23	Star Wars/Marvel/412. Darth Vader v02 - Shadows and Secrets.zip	to_parse
24	Star Wars/Marvel/435. Age Of Rebellion - Lando Calrissian.zip	to_parse
25	Star Wars/Marvel/001. Age of The Republic - Qui-Gon Jin.zip	to_parse
26	Star Wars/Marvel/306. Darth Vader - Dark Lord of the Sith v03 - The Burning Seas.zip	to_parse
27	Star Wars/Marvel/426. Doctor Aphra v04 - The Catastrophe Con.zip	to_parse
28	Star Wars/Marvel/312. Thrawn.zip	to_parse
29	Star Wars/Marvel/615. Age of Resistance - Finn.zip	to_parse
30	Star Wars/Marvel/601. The Force Awakens - Shattered Empire.zip	to_parse
31	Star Wars/Marvel/411. Star Wars v02 - Showdown on the Smuggler's Moon.zip	to_parse
32	Star Wars/Marvel/422. The Screaming Citadel.zip	to_parse
33	Star Wars/Marvel/551. Age Of Rebellion - Princess Leia.zip	to_parse
34	Star Wars/Marvel/613. Poe Dameron v04 - Legend Found.zip	to_parse
35	Star Wars/Marvel/433. Star Wars v11 - The Scourging Of Shu-Torun.zip	to_parse
36	Star Wars/Marvel/703. DJ - Most Wanted.zip	to_parse
37	Star Wars/Marvel/414. Darth Vader Annual 01.zip	to_parse
38	Star Wars/Marvel/437. Doctor Aphra v07 - A Rogue's End.zip	to_parse
39	Star Wars/Marvel/206. Darth Maul - Son of Dathomir.zip	to_parse
40	Star Wars/Marvel/416. Star Wars v03 - Rebel Jail.zip	to_parse
42	Star Wars/Marvel/428. Star Wars v07 - The Ashes of Jedha.zip	to_parse
43	Star Wars/Marvel/313. Rogue One - Cassian & K2SO.zip	to_parse
44	Star Wars/Marvel/432. Star Wars v10 - The Escape.zip	to_parse
45	Star Wars/Marvel/611. Poe Dameron v02 - The Gathering Storm.zip	to_parse
46	Star Wars/Marvel/418. Darth Vader v04 - End of Games.zip	to_parse
47	Star Wars/Marvel/408. Lando.zip	to_parse
48	Star Wars/Marvel/302. Kanan v02 - First Blood.zip	to_parse
49	Star Wars/Marvel/429. The Storms Of Crait.zip	to_parse
50	Star Wars/Marvel/803. Allegiance.zip	to_parse
51	Star Wars/Marvel/307. Darth Vader - Dark Lord of the Sith v04 - Fortress Vader.zip	to_parse
52	Star Wars/Marvel/202. Age of The Republic - Anakin Skywalker.zip	to_parse
53	Star Wars/Marvel/421. Doctor Aphra v01 - Aphra.zip	to_parse
54	Star Wars/Marvel/608. Age Of Resistance - Rose Tico.zip	to_parse
55	Star Wars/Marvel/614. Age of Resistance Special.zip	to_parse
56	Star Wars/Marvel/552. Tie Fighter.zip	to_parse
57	Star Wars/Marvel/423. Doctor Aphra v02 - Doctor Aphra and the Enormous Profit.zip	to_parse
58	Star Wars/Marvel/401. Age Of Rebellion - Grand Moff Tarkin.zip	to_parse
59	Star Wars/Marvel/406. Age Of Rebellion - Jabba The Hutt.zip	to_parse
60	Star Wars/Marvel/101. Age of The Republic - Obi-Wan Kenobi.zip	to_parse
61	Star Wars/Marvel/301. Kanan v01 - The Last Padawan.zip	to_parse
62	Star Wars/Marvel/801. Poe Dameron v05 - The Spark And The Fire.zip	to_parse
63	Star Wars/Marvel/604. Age of Resistance - Captain Phasma.zip	to_parse
64	Star Wars/Marvel/405. Age Of Rebellion - Boba Fett.zip	to_parse
65	Star Wars/Marvel/402. Princess Leia.zip	to_parse
66	Star Wars/Marvel/310. Han Solo - Imperial Cadet.zip	to_parse
67	Star Wars/Marvel/413. Star Wars Annual 01.zip	to_parse
68	Star Wars/Marvel/430. Star Wars v08 - Mutiny At Mon Cala.zip	to_parse
69	Star Wars/Marvel/802. Galaxy's Edge.zip	to_parse
70	Star Wars/Marvel/308. Jedi Fallen Order - Dark Temple 01-05.zip	to_parse
72	Star Wars/Marvel/102. Obi-Wan and Anakin.zip	to_parse
73	Star Wars/Marvel/407. Han Solo.zip	to_parse
74	Star Wars/Marvel/425. Doctor Aphra v03 - Remastered.zip	to_parse
75	Star Wars/Marvel/203. Age of The Republic - General Grievous.zip	to_parse
76	Star Wars/Marvel/002. Darth Maul.zip	to_parse
77	Star Wars/Marvel/309. Beckett.zip	to_parse
78	Star Wars/Marvel/605. Age of Resistance - Poe Dameron.zip	to_parse
79	Star Wars/Marvel/417. Darth Vader v03 - The Shu-Torun War.zip	to_parse
80	Star Wars/Marvel/419. Star Wars v04 - Last Flight of the Harbinger.zip	to_parse
81	Star Wars/Marvel/427. Doctor Aphra v05 - Worst Among Equals.zip	to_parse
82	Star Wars/Marvel/438. Star Wars v12 - Rebels And Rogues.zip	to_parse
83	Star Wars/Marvel/612. Poe Dameron v03 - Legend Lost.zip	to_parse
84	Star Wars/Marvel/303. Darth Vader - Dark Lord of the Sith v01 - Imperial Machine.zip	to_parse
85	Star Wars/Marvel/409. Star Wars v01 - Skywalker Strikes.zip	to_parse
87	Star Wars/Marvel/003. Age of The Republic - Darth Maul.zip	to_parse
88	Star Wars/Marvel/201. Jedi of the Republic - Mace Windu.zip	to_parse
89	Star Wars/Marvel/415. Vader Down.zip	to_parse
90	Star Wars/Marvel/404. Chewbacca.zip	to_parse
91	Star Wars/Marvel/420. Star Wars v05 - Yoda's Secret War.zip	to_parse
93	Star Wars/Dark Horse (Brian Wood)/Star Wars by Brian Wood v03 - Rebel Girl.zip	to_parse
94	Star Wars/Dark Horse (Brian Wood)/Star Wars by Brian Wood v02 - From the Ruins of Alderaan.zip	to_parse
95	Star Wars/Dark Horse (Brian Wood)/Star Wars by Brian Wood v04 - Shattered Hope.zip	to_parse
96	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 13-15 - High School.zip	to_parse
97	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 40-42 - Hawaii.zip	to_parse
98	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 50-60 - Vicky Weiss.zip	to_parse
99	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 26-32 - Veronica Pace.zip	to_parse
100	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 47-48 - Vicky Weiss.zip	to_parse
101	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 16 - Princess Warrior.zip	to_parse
102	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 34-38 - Veronica Pace.zip	to_parse
103	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 49 - Molly & Poo 01.zip	to_parse
104	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v1 01-03.zip	to_parse
105	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 80-90 - Life + Death.zip	to_parse
106	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 74-79 - Studio Katchoo.zip	to_parse
107	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 17-24 - HETA.zip	to_parse
108	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 01-12 - Darcy Parker.zip	to_parse
109	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 44-45 - Hawaii.zip	to_parse
110	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 73 - Molly & Poo 03.zip	to_parse
111	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 61-63 - David's Story.zip	to_parse
112	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 39 - You're a Loser.zip	to_parse
113	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 46 - Molly & Poo 02.zip	to_parse
114	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 67 - Bachelor Lawyer.zip	to_parse
115	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 33 - When Worlds Collide.zip	to_parse
116	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 64-66 - Art of Katchoo.zip	to_parse
117	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 25 - Hit the Beach.zip	to_parse
118	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 68-72 - Las Vegas.zip	to_parse
119	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v2 01-13.zip	to_parse
120	Terry Moore/01. Strangers in Paradise/Strangers in Paradise v3 43 - The Truth.zip	to_parse
121	Terry Moore/02. Echo/Echo v02 - Atomic Dreams 06-10.zip	to_parse
122	Terry Moore/02. Echo/Echo v01 - Moon Lake 01-05.zip	to_parse
123	Terry Moore/02. Echo/Echo v03 - Desert Run 11-15.zip	to_parse
124	Terry Moore/02. Echo/Echo v06 - The Last Day 26-30.zip	to_parse
125	Terry Moore/02. Echo/Echo v04 - Collider 16-20.zip	to_parse
126	Terry Moore/02. Echo/Echo v05 - Black Hole 21-25.zip	to_parse
127	Terry Moore/06. Five Years/Five Years 01-05.zip	to_parse
128	Terry Moore/04. Motor Girl/04. Motor Girl Omnibus.zip	to_parse
129	Terry Moore/03. Rachel Rising/Rachel Rising 19-24.zip	to_parse
130	Terry Moore/03. Rachel Rising/Rachel Rising 01-06.zip	to_parse
131	Terry Moore/03. Rachel Rising/Rachel Rising 13-18.zip	to_parse
132	Terry Moore/03. Rachel Rising/Rachel Rising 25-30.zip	to_parse
134	Terry Moore/03. Rachel Rising/Rachel Rising 37-42.zip	to_parse
135	Terry Moore/03. Rachel Rising/Rachel Rising 31-36.zip	to_parse
136	Terry Moore/05. Strangers in Paradise XXV/01. Strangers in Paradise v4 - XXV v01 - The Chase.zip	to_parse
137	Terry Moore/05. Strangers in Paradise XXV/02. Strangers in Paradise v4 - XXV 06-10.zip	to_parse
138	Valiant Comics/063. X-O Manowar v10 - Exodus.zip	to_parse
139	Valiant Comics/078. X-O Manowar Annual 2016.zip	to_parse
140	Valiant Comics/058. Imperium v02 - Broken Angels.zip	to_parse
141	Valiant Comics/064. Unity v05 - Homefront.zip	to_parse
142	Valiant Comics/096. Faith v04 - The Faithless.zip	to_parse
143	Valiant Comics/021. Unity v02 - Trapped By Webnet.zip	to_parse
144	Valiant Comics/043. The Delinquents.zip	to_parse
145	Valiant Comics/105. Divinity 00.zip	to_parse
146	Valiant Comics/076. Divinity II.zip	to_parse
147	Valiant Comics/121. Bloodshot's Day Off!.zip	to_parse
148	Valiant Comics/025. Bloodshot and H.A.R.D. Corps 18-19 + 00.zip	to_parse
149	Valiant Comics/055. Ivar, Timewalker v03 - Ending History.zip	to_parse
150	Valiant Comics/110. Secret Weapons 00.zip	to_parse
151	Valiant Comics/125. Quantum and Woody! v01 - Kiss Kiss Klang Klang.zip	to_parse
152	Valiant Comics/057. Imperium v01 - Collecting Monsters.zip	to_parse
153	Valiant Comics/119. War Mother.zip	to_parse
155	Valiant Comics/044. The Death-Defying Doctor Mirage.zip	to_parse
156	Valiant Comics/103. Bloodshot Reborn 00.zip	to_parse
157	Valiant Comics/074. Ninjak v03 - Operation Deadside.zip	to_parse
158	Valiant Comics/510. Doctor Mirage v01.zip	to_parse
159	Valiant Comics/109. Shadowman - Rae Sremmurd.zip	to_parse
160	Valiant Comics/095. Faith v03 - Superstar.zip	to_parse
161	Valiant Comics/040. Quantum and Woody v04 - Quantum and Woody Must Die!.zip	to_parse
162	Valiant Comics/084. A&A - The Adventures of Archer and Armstrong v01 - In the Bag.zip	to_parse
164	Valiant Comics/011. Archer & Armstrong v01 - The Michelangelo Code.zip	to_parse
165	Valiant Comics/019. X-O Manowar v04 - Homecoming.zip	to_parse
166	Valiant Comics/101. Divinity III - Heroes of the Glorious Stalinverse.zip	to_parse
167	Valiant Comics/122. Bloodshot Salvation v01 - The Book of Revenge.zip	to_parse
168	Valiant Comics/003. X-O Manowar v03 - Planet Death.zip	to_parse
169	Valiant Comics/008. Bloodshot v02 - The Rise and the Fall.zip	to_parse
170	Valiant Comics/001. X-O Manowar v01 - By the Sword.zip	to_parse
171	Valiant Comics/052. Bloodshot Reborn v02 - The Hunt.zip	to_parse
173	Valiant Comics/009. Harbinger Wars - Deluxe Edition.zip	to_parse
174	Valiant Comics/083. Faith v01 - Hollywood and Vine.zip	to_parse
175	Valiant Comics/100. Divinity III - Stalinverse.zip	to_parse
176	Valiant Comics/506. Punk Mambo.zip	to_parse
177	Valiant Comics/129. Shadowman v01 - Fear the Dark.zip	to_parse
178	Valiant Comics/117. X-O Manowar v03 - Emperor.zip	to_parse
179	Valiant Comics/508. KI-6 - Killers.zip	to_parse
180	Valiant Comics/066. Unity v07 - Revenge of the Armor Hunters.zip	to_parse
181	Valiant Comics/006. Bloodshot v01 - Setting the World on Fire.zip	to_parse
182	Valiant Comics/020. To Kill a King (from issues).zip	to_parse
183	Valiant Comics/053. Ivar, Timewalker v01 - Making History.zip	to_parse
184	Valiant Comics/086. 4001 A.D. Deluxe Edition.zip	to_parse
185	Valiant Comics/504. Livewire v02 - Guardian.zip	to_parse
186	Valiant Comics/012. Archer & Armstrong v02 - Wrath of the Eternal Warrior.zip	to_parse
187	Valiant Comics/050. Divinity.zip	to_parse
188	Valiant Comics/108. Rapture.zip	to_parse
189	Valiant Comics/069. Book of Death - Deluxe Edition.zip	to_parse
190	Valiant Comics/068. Dead Drop.zip	to_parse
191	Valiant Comics/023. Harbinger v05 - Death of a Renegade.zip	to_parse
192	Valiant Comics/102. X-O Manowar v01 - Soldier.zip	to_parse
193	Valiant Comics/107. X-O Manowar v02 - General.zip	to_parse
194	Valiant Comics/139. Shadowman v03 - Rag and Bone.zip	to_parse
195	Valiant Comics/045. Eternal Warrior - Days of Steel.zip	to_parse
196	Valiant Comics/079. X-O Manowar v12 - Long Live the King.zip	to_parse
197	Valiant Comics/037. Harbinger v06 - Omegas.zip	to_parse
198	Valiant Comics/500. X-O Manowar v07 - Hero.zip	to_parse
200	Valiant Comics/133. Harbinger Wars 2.zip	to_parse
201	Valiant Comics/073. The Death-Defying Doctor Mirage v02 - Second Lives.zip	to_parse
202	Valiant Comics/067. Rai v03 - The Orphan.zip	to_parse
203	Valiant Comics/024. Bloodshot and H.A.R.D. Corps 14-17 + Bloodshot 00.zip	to_parse
204	Valiant Comics/010. Eternal Warrior v01 - Sword of the Wild.zip	to_parse
205	Valiant Comics/034. Rai v01 - Welcome To New Japan.zip	to_parse
206	Valiant Comics/124. Ninja-K v01 - The Ninja Files.zip	to_parse
207	Valiant Comics/042. Archer & Armstrong v07 - The One Percent and Other Tales.zip	to_parse
208	Valiant Comics/016. Shadowman v03 - Deadside Blues.zip	to_parse
209	Valiant Comics/038. Unity v04 - United.zip	to_parse
210	Valiant Comics/013. Archer & Armstrong v03 - Far Faraway.zip	to_parse
211	Valiant Comics/033. Eternal Warrior v02 - Eternal Emperor.zip	to_parse
212	Valiant Comics/049. The Valiant.zip	to_parse
213	Valiant Comics/080. Bloodshot Reborn v03 - The Analog Man.zip	to_parse
214	Valiant Comics/098. Savage.zip	to_parse
215	Valiant Comics/007. Harbinger v02 - Renegades.zip	to_parse
216	Valiant Comics/087. Ninjak v05 - The Fist & The Steel.zip	to_parse
217	Valiant Comics/501. Incursion.zip	to_parse
218	Valiant Comics/114. Faith's Winter Wonderland Special.zip	to_parse
219	Valiant Comics/093. Bloodshot U.S.A.zip	to_parse
220	Valiant Comics/036. X-O Manowar 25 - segments bonus.zip	to_parse
221	Valiant Comics/113. Faith and the Future Force.zip	to_parse
222	Valiant Comics/082. Imperium v04 - Stormbreak.zip	to_parse
223	Valiant Comics/022 .Harbinger v04 - Perfect Day.zip	to_parse
224	Valiant Comics/505. The Life and Death of Toyo Harada.zip	to_parse
225	Valiant Comics/132. Ninjak vs. the Valiant Universe.zip	to_parse
226	Valiant Comics/507. Fallen World.zip	to_parse
227	Valiant Comics/047. X-O Manowar v08 - Enter Armorines.zip	to_parse
228	Valiant Comics/094. Faith v02 - California Scheming.zip	to_parse
230	Valiant Comics/061. Ninjak v02 - The Shadow Wars.zip	to_parse
231	Valiant Comics/502. The Forgotten Queen.zip	to_parse
232	Valiant Comics/072. Wrath of the Eternal Warrior v02 - Labyrinth.zip	to_parse
233	Valiant Comics/099. A&A - The Adventures of Archer and Armstrong v03 - Andromeda Estranged.zip	to_parse
234	Valiant Comics/090. Generation Zero v02 - Heroscape.zip	to_parse
235	Valiant Comics/081. Bloodshot Reborn v04 - Bloodshot Island.zip	to_parse
236	Valiant Comics/015. Shadowman v02 - Darque Reckoning.zip	to_parse
237	Valiant Comics/041. Archer & Armstrong v06 - American Wasteland.zip	to_parse
238	Valiant Comics/118. X-O Manowar v04 - Visigoth.zip	to_parse
239	Valiant Comics/509. Bloodshot v2 v01.zip	to_parse
240	Valiant Comics/075. Ninjak v04 - The Siege of King's Castle.zip	to_parse
241	Valiant Comics/031. Shadowman - End Times.zip	to_parse
242	Valiant Comics/503. Bloodshot Rising Spirit 01-08.zip	to_parse
243	Valiant Comics/134. Quantum and Woody! v02 - Separation Anxiety.zip	to_parse
244	Valiant Comics/138. Britannia v03 - Lost Eagles of Rome.zip	to_parse
245	Valiant Comics/512. Livewire 09-12.zip	to_parse
246	Valiant Comics/141. Livewire v01 - Fugitive.zip	to_parse
247	Valiant Comics/018. Quantum and Woody v02 - In Security.zip	to_parse
248	Valiant Comics/097. Harbinger Renegade v01 - The Judgment of Solomon.zip	to_parse
310	comics à trier/comics/The X-Files Funko Universe (2017) GetComics.INFO.cbr	to_unzip
312	comics à trier/comics/Judge Dredd Funko Universe (2017) GetComics.INFO.cbr	to_unzip
313	comics à trier/comics/Charles Burns - X'ed Out.cbr	to_unzip
250	Valiant Comics/014. Shadowman v01 - Birth Rites.zip	to_parse
251	Valiant Comics/136. X-O Manowar v06 - Agent.zip	to_parse
252	Valiant Comics/060. Ninjak v01 - Weaponeer.zip	to_parse
253	Valiant Comics/051. Bloodshot Reborn v01 - Colorado.zip	to_parse
254	Valiant Comics/140. Faith - Dreamside.zip	to_parse
255	Valiant Comics/054. Ivar, Timewalker v02 - Breaking History.zip	to_parse
256	Valiant Comics/065. Unity v06 - The War-Monger.zip	to_parse
257	Valiant Comics/062. X-O Manowar v09 - Dead Hand.zip	to_parse
258	Valiant Comics/131. Valiant High.zip	to_parse
260	Valiant Comics/130. Shadowman v02 - Dead and Gone.zip	to_parse
261	Valiant Comics/002. X-O Manowar v02 - Enter Ninjak.zip	to_parse
262	Valiant Comics/135. X-O Manowar v05 - Barbarians.zip	to_parse
263	Valiant Comics/039. Quantum and Woody v03 - Crooked Pasts, Present Tense.zip	to_parse
264	Valiant Comics/048. Rai v02 - Battle For New Japan.zip	to_parse
265	Valiant Comics/511. Roku 01-04.zip	to_parse
266	Valiant Comics/104. Rai - The History of the Valiant Universe.zip	to_parse
267	Valiant Comics/112. Secret Weapons - Owen's Story.zip	to_parse
268	Valiant Comics/120. Eternity.zip	to_parse
269	Valiant Comics/089. Generation Zero v01 - We are the Future.zip	to_parse
270	Valiant Comics/123. Ninjak 00.zip	to_parse
271	Valiant Comics/127. Bloodshot Salvation v03 - The Book of Revelations.zip	to_parse
272	Valiant Comics/059. Imperium v03 - The Vine Imperative.zip	to_parse
273	Valiant Comics/029. Shadowman 13X.zip	to_parse
274	Valiant Comics/137. Ninja-K v03 - Fallout.zip	to_parse
275	Valiant Comics/085. A&A - The Adventures of Archer and Armstrong v02 - Romance and Road Trips.zip	to_parse
276	Valiant Comics/032. Punk Mambo 00.zip	to_parse
277	Valiant Comics/128. Ninja-K v02 - The Coalition.zip	to_parse
278	Valiant Comics/004. Harbinger v01 - Omega Rising.zip	to_parse
279	Valiant Comics/046. Bloodshot v06 - The Glitch and Other Tales.zip	to_parse
280	Valiant Comics/005. Harbinger 00.zip	to_parse
281	Valiant Comics/071. Wrath of the Eternal Warrior v01 - Risen.zip	to_parse
282	Valiant Comics/056. Imperium - Prelude.zip	to_parse
283	Valiant Comics/077. X-O Manowar v11 - The Kill List.zip	to_parse
284	Valiant Comics/106. Britannia v02 - We Who Are About to Die.zip	to_parse
285	Valiant Comics/088. Ninjak v06 - The Seven Blades of Master Darque.zip	to_parse
287	Valiant Comics/027. Archer & Armstrong v05 - Mission - Improbable.zip	to_parse
288	Valiant Comics/115. Armstrong and the Vault of Spirits.zip	to_parse
289	Valiant Comics/091. Britannia.zip	to_parse
290	Valiant Comics/035. Armor Hunters - Deluxe Edition.zip	to_parse
291	Valiant Comics/111. Secret Weapons.zip	to_parse
292	comics à trier/Sugar Skull (Charles Burns-Pantheon 2014) (edge).cbz	to_parse
293	comics à trier/comics/City of Crime/Detective Comics 812 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
294	comics à trier/comics/City of Crime/Detective Comics 808 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
295	comics à trier/comics/City of Crime/Detective Comics 813 (2006) (Digital) (AnHeroGold-Empire).cbz	to_parse
296	comics à trier/comics/City of Crime/Detective Comics 802 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
297	comics à trier/comics/City of Crime/Detective Comics 814 (2006) (digital-Empire).cbz	to_parse
298	comics à trier/comics/City of Crime/Detective Comics 804 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
299	comics à trier/comics/City of Crime/Detective Comics 807 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
300	comics à trier/comics/City of Crime/Detective Comics 805 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
301	comics à trier/comics/City of Crime/Detective Comics 800 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
302	comics à trier/comics/City of Crime/Detective Comics 806 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
303	comics à trier/comics/City of Crime/Detective Comics 801 (2005) (digital-Empire).cbz	to_parse
304	comics à trier/comics/City of Crime/Detective Comics 811 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
305	comics à trier/comics/City of Crime/Detective Comics 803 (2005) (Digital) (AnHeroGold-Empire).cbz	to_parse
306	comics à trier/comics/Locke & Key - Extras/Locke & Key - Introduction (2008) (Digital) (G85-Empire).zip	to_parse
307	comics à trier/comics/Locke & Key - Extras/Locke & Key - Art Gallery (2008) (Digital) (G85-Empire).zip	to_parse
308	comics à trier/comics/Locke & Key - Extras/Locke & Key - Small World 001 (2016) GetComics.INFO.zip	to_parse
311	comics à trier/comics/Charles Burns - Sugar Skull.cbz	to_parse
314	comics à trier/012. Swamp Thing v03 - The Curse.zip	to_parse
315	comics à trier/Marvel Zombies/Marvel Zombies Christmas Carol (01 - 05) (2011) (Minutemen-DarthItsy)/Marvel Zombies Christmas Carol 02 (of 05) (2011) (Minutemen-DarthItsy).cbz	to_parse
316	comics à trier/Marvel Zombies/Marvel Zombies Christmas Carol (01 - 05) (2011) (Minutemen-DarthItsy)/Marvel Zombies Christmas Carol 04 (of 05) (2011) (Minutemen-DarthItsy).cbz	to_parse
317	comics à trier/Marvel Zombies/Marvel Zombies Christmas Carol (01 - 05) (2011) (Minutemen-DarthItsy)/Marvel Zombies Christmas Carol 03 (of 05) (2011) (Minutemen-DarthItsy).cbz	to_parse
318	comics à trier/Marvel Zombies/Marvel Zombies Christmas Carol (01 - 05) (2011) (Minutemen-DarthItsy)/Marvel Zombies Christmas Carol 01 (of 05) (2011) (Minutemen-DarthItsy).cbz	to_parse
319	comics à trier/Marvel Zombies/Marvel Zombies Christmas Carol (01 - 05) (2011) (Minutemen-DarthItsy)/Marvel Zombies Christmas Carol 05 (of 05) (2011) (Minutemen-DarthItsy).cbz	to_parse
321	comics à trier/Marvel Zombies/Marvel Zombies vs. Army Of Darkness (01 - 05) (2007) (Minutemen-DarthScanner)/Marvel Zombies vs Army Of Darkness 05 (of 05) (2007) (Minutemen-DarthScanner).zip	to_parse
322	comics à trier/Marvel Zombies/Marvel Zombies vs. Army Of Darkness (01 - 05) (2007) (Minutemen-DarthScanner)/Marvel Zombies vs Army Of Darkness 02 (of 05) (2007) (Minutemen-DarthScanner).zip	to_parse
323	comics à trier/Marvel Zombies/Marvel Zombies vs. Army Of Darkness (01 - 05) (2007) (Minutemen-DarthScanner)/Marvel Zombies vs Army Of Darkness 01 (of 05) (2007) (Minutemen-DarthScanner).zip	to_parse
324	comics à trier/Marvel Zombies/Marvel Zombies vs. Army Of Darkness (01 - 05) (2007) (Minutemen-DarthScanner)/Marvel Zombies vs Army Of Darkness 03 (of 05) (2007) (Minutemen-DarthScanner).zip	to_parse
325	comics à trier/Marvel Zombies/Marvel Zombies Supreme (01 - 05) (2011) (digital) (Minutemen-PhD)/Marvel Zombies Supreme 01 (of 05) (2011) (digital) (Minutemen-PhD).zip	to_parse
326	comics à trier/Marvel Zombies/Marvel Zombies Supreme (01 - 05) (2011) (digital) (Minutemen-PhD)/Marvel Zombies Supreme 02 (of 05) (2011) (digital) (Minutemen-PhD).zip	to_parse
327	comics à trier/Marvel Zombies/Marvel Zombies Supreme (01 - 05) (2011) (digital) (Minutemen-PhD)/Marvel Zombies Supreme 03 (of 05) (2011) (digital) (Minutemen-PhD).zip	to_parse
328	comics à trier/Marvel Zombies/Marvel Zombies Supreme (01 - 05) (2011) (digital) (Minutemen-PhD)/Marvel Zombies Supreme 04 (of 05) (2011) (digital) (Minutemen-PhD).zip	to_parse
329	comics à trier/Marvel Zombies/Marvel Zombies Supreme (01 - 05) (2011) (digital) (Minutemen-PhD)/Marvel Zombies Supreme 05 (of 05) (2011) (digital) (Minutemen-PhD).zip	to_parse
330	comics à trier/Marvel Zombies/Marvel Zombies Destroy (01 - 05) (2012) (digital) (Minutemen-PhD)/Marvel Zombies Destroy! 02 (of 05) (2012) (digital) (Minutemen-PhD).zip	to_parse
332	comics à trier/Marvel Zombies/Marvel Zombies Destroy (01 - 05) (2012) (digital) (Minutemen-PhD)/Marvel Zombies Destroy! 03 (of 05) (2012) (digital) (Minutemen-PhD).zip	to_parse
333	comics à trier/Marvel Zombies/Marvel Zombies Destroy (01 - 05) (2012) (digital) (Minutemen-PhD)/Marvel Zombies Destroy! 01 (of 05) (2012) (digital) (Minutemen-PhD).zip	to_parse
334	comics à trier/Marvel Zombies/Marvel Zombies Destroy (01 - 05) (2012) (digital) (Minutemen-PhD)/Marvel Zombies Destroy! 05 (of 05) (2012) (digital) (Minutemen-PhD).zip	to_parse
335	comics à trier/Marvel Zombies/Marvel Zombies 1 (01 - 05) (2006) (digital) (Minutemen-PhD)/Marvel Zombies 04 (of 05) (2006) (digital) (Minutemen-PhD).zip	to_parse
336	comics à trier/Marvel Zombies/Marvel Zombies 1 (01 - 05) (2006) (digital) (Minutemen-PhD)/Marvel Zombies 02 (of 05) (2006) (digital) (Minutemen-PhD).zip	to_parse
337	comics à trier/Marvel Zombies/Marvel Zombies 1 (01 - 05) (2006) (digital) (Minutemen-PhD)/Marvel Zombies 01 (of 05) (2006) (digital) (Minutemen-PhD).zip	to_parse
338	comics à trier/Marvel Zombies/Marvel Zombies 1 (01 - 05) (2006) (digital) (Minutemen-PhD)/Marvel Zombies 05 (of 05) (2006) (digital) (Minutemen-PhD).zip	to_parse
339	comics à trier/Marvel Zombies/Marvel Zombies 1 (01 - 05) (2006) (digital) (Minutemen-PhD)/Marvel Zombies 03 (of 05) (2006) (digital) (Minutemen-PhD).zip	to_parse
340	comics à trier/Marvel Zombies/Marvel Zombies 5 (01 - 05) (2010) (digital) (Minutemen-InnerDemons)/Marvel Zombies 5 03 (of 05) (2010) (digital) (Minutemen-InnerDemons).zip	to_parse
341	comics à trier/Marvel Zombies/Marvel Zombies 5 (01 - 05) (2010) (digital) (Minutemen-InnerDemons)/Marvel Zombies 5 05 (of 05) (2010) (digital) (Minutemen-InnerDemons).zip	to_parse
342	comics à trier/Marvel Zombies/Marvel Zombies 5 (01 - 05) (2010) (digital) (Minutemen-InnerDemons)/Marvel Zombies 5 01 (of 05) (2010) (digital) (Minutemen-InnerDemons).zip	to_parse
343	comics à trier/Marvel Zombies/Marvel Zombies 5 (01 - 05) (2010) (digital) (Minutemen-InnerDemons)/Marvel Zombies 5 04 (of 05) (2010) (digital) (Minutemen-InnerDemons).zip	to_parse
344	comics à trier/Marvel Zombies/Marvel Zombies 5 (01 - 05) (2010) (digital) (Minutemen-InnerDemons)/Marvel Zombies 5 02 (of 05) (2010) (digital) (Minutemen-InnerDemons).zip	to_parse
345	comics à trier/Marvel Zombies/Marvel Zombies - Dead Days 01 (2007) (digital) (Minutemen-PhD).zip	to_parse
346	comics à trier/Marvel Zombies/Marvel Spotlight - Marvel Zombies - Mystic Arcana (2007) (c2c) (Green-Engine-DCP).zip	to_parse
347	comics à trier/Marvel Zombies/Marvel Zombies 4 (01 - 04) (2009) (digital) (Minutemen-PhD)/Marvel Zombies 4 03 (of 04) (2009) (digital) (Minutemen-PhD).zip	to_parse
348	comics à trier/Marvel Zombies/Marvel Zombies 4 (01 - 04) (2009) (digital) (Minutemen-PhD)/Marvel Zombies 4 01 (of 04) (2009) (digital) (Minutemen-PhD).zip	to_parse
349	comics à trier/Marvel Zombies/Marvel Zombies 4 (01 - 04) (2009) (digital) (Minutemen-PhD)/Marvel Zombies 4 04 (of 04) (2009) (digital) (Minutemen-PhD).zip	to_parse
350	comics à trier/Marvel Zombies/Marvel Zombies 4 (01 - 04) (2009) (digital) (Minutemen-PhD)/Marvel Zombies 4 02 (of 04) (2009) (digital) (Minutemen-PhD).zip	to_parse
351	comics à trier/Marvel Zombies/Marvel Zombies 3 (01 - 04) (2008 - 2009) (Digital) (Cypher-Empire)/Marvel Zombies 3 01 (of 04) (2008) (Digital) (Cypher-Empire).zip	to_parse
352	comics à trier/Marvel Zombies/Marvel Zombies 3 (01 - 04) (2008 - 2009) (Digital) (Cypher-Empire)/Marvel Zombies 3 02 (of 04) (2009) (Digital) (Cypher-Empire).zip	to_parse
353	comics à trier/Marvel Zombies/Marvel Zombies 3 (01 - 04) (2008 - 2009) (Digital) (Cypher-Empire)/Marvel Zombies 3 03 (of 04) (2009) (Digital) (Cypher-Empire).zip	to_parse
354	comics à trier/Marvel Zombies/Marvel Zombies 3 (01 - 04) (2008 - 2009) (Digital) (Cypher-Empire)/Marvel Zombies 3 04 (of 04) (2009) (Digital) (Cypher-Empire).zip	to_parse
355	comics à trier/Marvel Zombies/Marvel Zombies - The Book of Angels, Demons, & Various Monstrosities (Handbook).zip	to_parse
356	comics à trier/Marvel Zombies/Marvel Zombies Return (01 - 05) (2009) (Digital) (Cypher-Empire)/Marvel Zombies Return 04 (of 05) (2010) (Digital) (Cypher-Empire).zip	to_parse
357	comics à trier/Marvel Zombies/Marvel Zombies Return (01 - 05) (2009) (Digital) (Cypher-Empire)/Marvel Zombies Return 05 (of 05) (2010) (Digital) (Cypher-Empire).zip	to_parse
358	comics à trier/Marvel Zombies/Marvel Zombies Return (01 - 05) (2009) (Digital) (Cypher-Empire)/Marvel Zombies Return 03 (of 05) (2010) (Digital) (Cypher-Empire).zip	to_parse
487	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Nevermore/Nevermore 02.zip	to_parse
360	comics à trier/Marvel Zombies/Marvel Zombies Return (01 - 05) (2009) (Digital) (Cypher-Empire)/Marvel Zombies Return 01 (of 05) (2009) (Digital) (Cypher-Empire).zip	to_parse
361	comics à trier/Marvel Zombies/Marvel Zombies - Halloween 01 (2012) (digital) (Minutemen-PhD).zip	to_parse
362	comics à trier/Marvel Zombies/Marvel Zombies 2 (01 - 05) (2007 - 2008) (digital) (Minutemen-PhD)/Marvel Zombies 2 04 (of 05) (2008) (digital) (Minutemen-PhD).zip	to_parse
363	comics à trier/Marvel Zombies/Marvel Zombies 2 (01 - 05) (2007 - 2008) (digital) (Minutemen-PhD)/Marvel Zombies 2 02 (of 05) (2008) (digital) (Minutemen-PhD).zip	to_parse
364	comics à trier/Marvel Zombies/Marvel Zombies 2 (01 - 05) (2007 - 2008) (digital) (Minutemen-PhD)/Marvel Zombies 2 03 (of 05) (2008) (digital) (Minutemen-PhD).zip	to_parse
365	comics à trier/Marvel Zombies/Marvel Zombies 2 (01 - 05) (2007 - 2008) (digital) (Minutemen-PhD)/Marvel Zombies 2 05 (of 05) (2008) (digital) (Minutemen-PhD).zip	to_parse
366	comics à trier/Marvel Zombies/Marvel Zombies 2 (01 - 05) (2007 - 2008) (digital) (Minutemen-PhD)/Marvel Zombies 2 01 (of 05) (2007) (digital) (Minutemen-PhD).zip	to_parse
367	comics à trier/Marvel Zombies/Marvel Zombies - Evil Evolution 01 (2009) (digital) (Minutemen-PhD).zip	to_parse
368	DC/00. Elseworlds & autres histoires/The Wild Storm v04 19-24.zip	to_parse
369	DC/00. Elseworlds & autres histoires/Batman Black and White v03.zip	to_parse
370	DC/00. Elseworlds & autres histoires/Gotham City Garage 01-12.zip	to_parse
371	DC/00. Elseworlds & autres histoires/Superman vs Flash.zip	to_parse
372	DC/00. Elseworlds & autres histoires/The Spirit 07-13.zip	to_parse
373	DC/00. Elseworlds & autres histoires/The Wildstorm - Michael Cray v01.zip	to_parse
374	DC/00. Elseworlds & autres histoires/Thrillkiller.zip	to_parse
375	DC/00. Elseworlds & autres histoires/Gotham Noir.zip	to_parse
376	DC/00. Elseworlds & autres histoires/Li'l Gotham/02. Li'l Gotham 13-24.zip	to_parse
377	DC/00. Elseworlds & autres histoires/Li'l Gotham/01. Li'l Gotham v01 - A Lot of Li'l Gotham.zip	to_parse
378	DC/00. Elseworlds & autres histoires/Under the Moon - A Catwoman Tale.zip	to_parse
379	DC/00. Elseworlds & autres histoires/Gotham by Gaslight.zip	to_parse
380	DC/00. Elseworlds & autres histoires/Batman Vampire v02 - Bloodstorm.zip	to_parse
382	DC/00. Elseworlds & autres histoires/Batman - War on Crime.zip	to_parse
383	DC/00. Elseworlds & autres histoires/Batman - Sins of the Father.zip	to_parse
384	DC/00. Elseworlds & autres histoires/Creature of the Night 01-04.zip	to_parse
385	DC/00. Elseworlds & autres histoires/Batman - Through the Looking Glass.zip	to_parse
386	DC/00. Elseworlds & autres histoires/Mad Love and Other Stories.zip	to_parse
387	DC/00. Elseworlds & autres histoires/Batman - Teenage Mutant Ninja Turtles I - The Deluxe Edition.zip	to_parse
388	DC/00. Elseworlds & autres histoires/Batman - Elmer Fudd Special.zip	to_parse
389	DC/00. Elseworlds & autres histoires/Batman - Teenage Mutant Ninja Turtles II.zip	to_parse
390	DC/00. Elseworlds & autres histoires/All-Star Batman and Robin, The Boy Wonder 10.zip	to_parse
391	DC/00. Elseworlds & autres histoires/Justice Riders.zip	to_parse
392	DC/00. Elseworlds & autres histoires/Last Son of Earth.zip	to_parse
393	DC/00. Elseworlds & autres histoires/The Wildstorm - Michael Cray v02.zip	to_parse
394	DC/00. Elseworlds & autres histoires/The Doom That Came to Gotham.zip	to_parse
395	DC/00. Elseworlds & autres histoires/The Dark Knight Returns v03 - The Master Race.zip	to_parse
396	DC/00. Elseworlds & autres histoires/Batman - Kings of Fear.zip	to_parse
397	DC/00. Elseworlds & autres histoires/JSA Elseworlds v01 - The Liberty File.zip	to_parse
398	DC/00. Elseworlds & autres histoires/Damian - Son of Batman.zip	to_parse
399	DC/00. Elseworlds & autres histoires/Batman - White Knight v01.zip	to_parse
400	DC/00. Elseworlds & autres histoires/The New Frontier.cbz	to_parse
401	DC/00. Elseworlds & autres histoires/The Batman - Judge Dredd Collection.zip	to_parse
402	DC/00. Elseworlds & autres histoires/Year 100 and Other Tales.zip	to_parse
403	DC/00. Elseworlds & autres histoires/Batman - Damned 01-03.zip	to_parse
404	DC/00. Elseworlds & autres histoires/Batman - Harley and Ivy The Deluxe Edition.zip	to_parse
405	DC/00. Elseworlds & autres histoires/Batman Black and White v04.zip	to_parse
406	DC/00. Elseworlds & autres histoires/Superman & Bugs Bunny.zip	to_parse
407	DC/00. Elseworlds & autres histoires/Batman - White Knight v02 - Curse Of The White Knight 01-08.zip	to_parse
408	DC/00. Elseworlds & autres histoires/Nine Lives.zip	to_parse
409	DC/00. Elseworlds & autres histoires/Batman Chronicles #11.zip	to_parse
410	DC/00. Elseworlds & autres histoires/Superman Earth One v02.zip	to_parse
411	DC/00. Elseworlds & autres histoires/Batman - The Dark Prince Charming.zip	to_parse
412	DC/00. Elseworlds & autres histoires/Batman In Noir Alley.zip	to_parse
413	DC/00. Elseworlds & autres histoires/The Wild Storm v01.zip	to_parse
414	DC/00. Elseworlds & autres histoires/Batman Noir - Eduardo Risso - The Deluxe Edition.zip	to_parse
415	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/14. Injustice 2 v01.zip	to_parse
416	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/13. Injustice - Ground Zero v02.zip	to_parse
418	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/08. Injustice - Gods Among Us v08 - Year 4 02.zip	to_parse
419	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/10. Injustice - Gods Among Us v10 - Year 5 02.zip	to_parse
420	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/03. Injustice - Gods Among Us v03 - Year 2 01.zip	to_parse
421	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/05. Injustice - Gods Among Us v05 - Year 3 01.zip	to_parse
422	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/18. Injustice 2 v05.zip	to_parse
2121	Fini/The White Suits 01-04.zip	to_parse
424	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/19. Injustice 2 v06.zip	to_parse
425	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/01. Injustice - Gods Among Us v01 - Year 1 01.zip	to_parse
426	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/04. Injustice - Gods Among Us v04 - Year 2 02.zip	to_parse
427	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/16. Injustice 2 v03.zip	to_parse
428	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/17. Injustice 2 v04.zip	to_parse
429	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/06. Injustice - Gods Among Us v06 - Year 3 02.zip	to_parse
430	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/15. Injustice 2 v02.zip	to_parse
431	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/20. Injustice vs. Masters of the Universe.zip	to_parse
432	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/09. Injustice - Gods Among Us v09 - Year 5 01.zip	to_parse
433	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/02. Injustice - Gods Among Us v02 - Year 1 02.zip	to_parse
434	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/07. Injustice - Gods Among Us v07 - Year 4 01.zip	to_parse
435	DC/00. Elseworlds & autres histoires/Batman - White Knight v03 - Von Freeze.zip	to_parse
436	DC/00. Elseworlds & autres histoires/Joker - Killer Smile 01-03.zip	to_parse
437	DC/00. Elseworlds & autres histoires/The Spirit 01-06 + Batman and the Spirit special.zip	to_parse
438	DC/00. Elseworlds & autres histoires/Speeding Bullets.zip	to_parse
439	DC/00. Elseworlds & autres histoires/The Nail.zip	to_parse
440	DC/00. Elseworlds & autres histoires/Batman - Nightwalker.zip	to_parse
441	DC/00. Elseworlds & autres histoires/Batman - Teenage Mutant Ninja Turtles III 01-06.zip	to_parse
442	DC/00. Elseworlds & autres histoires/Batman Vampire v03 - Crimson mist.zip	to_parse
443	DC/00. Elseworlds & autres histoires/Superman - Secret Identity.zip	to_parse
444	DC/00. Elseworlds & autres histoires/Lumberjanes - Gotham Academy.zip	to_parse
445	DC/00. Elseworlds & autres histoires/Batman Black and White v02.zip	to_parse
446	DC/00. Elseworlds & autres histoires/Superman Year One - 01-03.zip	to_parse
448	DC/00. Elseworlds & autres histoires/All-Star Superman.zip	to_parse
449	DC/00. Elseworlds & autres histoires/The Dark Knight Returns v03.5 - The Master RaceThe Covers Deluxe Edition.zip	to_parse
450	DC/00. Elseworlds & autres histoires/Exit Stage Left - The Snagglepuss Chronicles 01-06.zip	to_parse
451	DC/00. Elseworlds & autres histoires/Harleen 01-03.zip	to_parse
452	DC/00. Elseworlds & autres histoires/Gotham City Garage 13-24.zip	to_parse
453	DC/00. Elseworlds & autres histoires/The Wild Storm v02.zip	to_parse
454	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Age of Wonder/Age of Wonder 01.zip	to_parse
455	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Age of Wonder/Age of Wonder 02.zip	to_parse
456	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Holy Terror.cbz	to_parse
457	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Batman & Captain America.zip	to_parse
458	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/A trier/League of Justice/League of Justice 02.zip	to_parse
459	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/A trier/League of Justice/League of Justice 01.zip	to_parse
460	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/A trier/Superman vs. Dracula.zip	to_parse
461	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/A trier/Superman and Spider Man.zip	to_parse
462	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Batman & Houdini - The Devil's Workshop.zip	to_parse
463	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Last Stand On Krypton.zip	to_parse
464	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Evil's Might/Evil's Might 01.zip	to_parse
465	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Evil's Might/Evil's Might 03.zip	to_parse
466	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Evil's Might/Evil's Might 02.zip	to_parse
467	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Dark Side.cbz	to_parse
468	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Superman vs. Muhammed Ali.cbz	to_parse
469	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/DC vs. Dark Horse Comics Justice League.zip	to_parse
470	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Two Faces.zip	to_parse
471	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 07.zip	to_parse
472	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 03.zip	to_parse
473	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 01.zip	to_parse
474	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 09.zip	to_parse
475	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 06.zip	to_parse
476	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 05.zip	to_parse
477	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 04.zip	to_parse
478	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 08.zip	to_parse
479	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 02.zip	to_parse
480	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 12.zip	to_parse
481	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 11.zip	to_parse
482	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/The Kents/The Kents 10.zip	to_parse
483	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/War Of The Worlds.cbz	to_parse
484	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Nevermore/Nevermore 05.zip	to_parse
485	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Nevermore/Nevermore 04.zip	to_parse
486	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Nevermore/Nevermore 01.zip	to_parse
489	DC/00. Elseworlds & autres histoires/Batman vs. Predator.zip	to_parse
491	DC/00. Elseworlds & autres histoires/JSA Elseworlds v02 - The Unholy Three.zip	to_parse
492	DC/00. Elseworlds & autres histoires/Batman Vampire v01 - Red Rain.zip	to_parse
493	DC/00. Elseworlds & autres histoires/All-Star Batman and Robin, The Boy Wonder 01-09.zip	to_parse
494	DC/00. Elseworlds & autres histoires/The Wild Storm v03.zip	to_parse
495	DC/00. Elseworlds & autres histoires/Superman - American Alien.zip	to_parse
496	DC/00. Elseworlds & autres histoires/Batman Black and White v01.zip	to_parse
497	DC/00. Elseworlds & autres histoires/Batman - Ego and Other Tails.zip	to_parse
498	DC/00. Elseworlds & autres histoires/Batman Tales - Once Upon a Crime.zip	to_parse
499	DC/03. Rebirth/056. Batman v3 16-20 - I am Bane.zip	to_parse
500	DC/03. Rebirth/102. Action Comics 987-991.zip	to_parse
501	DC/03. Rebirth/111. Metal.zip	to_parse
502	DC/03. Rebirth/158. Nightwing 50-56.zip	to_parse
503	DC/03. Rebirth/152. Hal Jordan and the Green Lantern Corps 48-50.zip	to_parse
504	DC/03. Rebirth/020. Superman v4 08-09.zip	to_parse
505	DC/03. Rebirth/130. Super Sons 15-16.zip	to_parse
506	DC/03. Rebirth/027. Nightwing v4 09.zip	to_parse
507	DC/03. Rebirth/123. Batman v3 41-43.zip	to_parse
508	DC/03. Rebirth/161. Justice League Dark v2 01-03.zip	to_parse
509	DC/03. Rebirth/169. Detective Comics 988-993.zip	to_parse
510	DC/03. Rebirth/067. Batman v3 & The Flash v5 - The Button.zip	to_parse
511	DC/03. Rebirth/098. Batman v3 v04 - The War of Jokes and Riddles.zip	to_parse
512	DC/03. Rebirth/A ordonner/Tales From The Dark Multiverse - Infinite Crisis.zip	to_parse
513	DC/03. Rebirth/A ordonner/Tales From The Dark Multiverse - Death of Superman.zip	to_parse
514	DC/03. Rebirth/A ordonner/Black Adam - Year of the Villain.zip	to_parse
515	DC/03. Rebirth/A ordonner/Superman - Villains.zip	to_parse
516	DC/03. Rebirth/A ordonner/Batman v3 Annual 04.zip	to_parse
517	DC/03. Rebirth/A ordonner/Year of the Villain - Hell Arisen 01-04.zip	to_parse
518	DC/03. Rebirth/A ordonner/The Infected - Scarab.zip	to_parse
519	DC/03. Rebirth/A ordonner/Harley Quinn -  Villain Of The Year.zip	to_parse
520	DC/03. Rebirth/A ordonner/Catwoman v5 09-13.zip	to_parse
521	DC/03. Rebirth/A ordonner/New Year's Evil.zip	to_parse
522	DC/03. Rebirth/A ordonner/Gotham City Monsters 01-06.zip	to_parse
523	DC/03. Rebirth/A ordonner/The Infected - Deathbringer.zip	to_parse
525	DC/03. Rebirth/A ordonner/Tales From The Dark Multiverse - Teen Titans - The Judas Contract.zip	to_parse
526	DC/03. Rebirth/A ordonner/The Infected - King SHAZAM!.zip	to_parse
527	DC/03. Rebirth/A ordonner/DCeased 01-06 + A Good Day to Die.zip	to_parse
528	DC/03. Rebirth/A ordonner/Lex Luthor - Year Of The Villain.zip	to_parse
529	DC/03. Rebirth/A ordonner/The Silencer 16-17.zip	to_parse
530	DC/03. Rebirth/A ordonner/198. Superman - Leviathan Rising Special.zip	to_parse
531	DC/03. Rebirth/A ordonner/Justice League Dark v2 08-12.zip	to_parse
532	DC/03. Rebirth/A ordonner/194. DC 's Year of the Villain Special 01.zip	to_parse
533	DC/03. Rebirth/A ordonner/Tales From The Dark Multiverse - Batman Knightfall.zip	to_parse
534	DC/03. Rebirth/A ordonner/193. Batman v3 66-69.zip	to_parse
535	DC/03. Rebirth/A ordonner/Justice League v4 19-25.zip	to_parse
536	DC/03. Rebirth/A ordonner/Justice League Dark v2 13-19 + Annual 01 - The Witching War.zip	to_parse
537	DC/03. Rebirth/A ordonner/The Riddler - Year of the Villain.zip	to_parse
538	DC/03. Rebirth/A ordonner/Batman - Pennyworth R.I.P.zip	to_parse
539	DC/03. Rebirth/A ordonner/Superman - Heroes.zip	to_parse
540	DC/03. Rebirth/A ordonner/Joker - Year Of The Villain.zip	to_parse
541	DC/03. Rebirth/A ordonner/The Silencer 14-15.zip	to_parse
542	DC/03. Rebirth/A ordonner/The Infected - The Commissioner.zip	to_parse
543	DC/03. Rebirth/A ordonner/Batman - Last Knight on Earth 01-03.zip	to_parse
544	DC/03. Rebirth/A ordonner/188. Batman v3 58-63.zip	to_parse
545	DC/03. Rebirth/A ordonner/Batman v3 75-85.zip	to_parse
546	DC/03. Rebirth/A ordonner/Tales From The Dark Multiverse - Blackest Night.zip	to_parse
547	DC/03. Rebirth/A ordonner/Batman v3 70-74.zip	to_parse
548	DC/03. Rebirth/A ordonner/Sinestro - Year of the Villain.zip	to_parse
550	DC/03. Rebirth/A ordonner/197. Action Comis 1007-1011 - Leviathan Rises.zip	to_parse
551	DC/03. Rebirth/A ordonner/Batman & the Outsiders v3 Annual 01.zip	to_parse
552	DC/03. Rebirth/A ordonner/Detective Comics 1001-1005 + Annual 02.zip	to_parse
553	DC/03. Rebirth/A ordonner/Superman v5 07-14.zip	to_parse
554	DC/03. Rebirth/A ordonner/Justice League Odyssey 06-12.zip	to_parse
555	DC/03. Rebirth/A ordonner/Batman & the Outsiders v3 01-06.zip	to_parse
556	DC/03. Rebirth/A ordonner/Batman Universe 01-06.zip	to_parse
557	DC/03. Rebirth/A ordonner/Batman v3 Secret Files 02.zip	to_parse
558	DC/03. Rebirth/A ordonner/Black Mask - Year of the Villain.zip	to_parse
559	DC/03. Rebirth/A ordonner/Justice League v4 26-28.zip	to_parse
560	DC/03. Rebirth/A ordonner/Hawkman v5 08-12.zip	to_parse
561	DC/03. Rebirth/017. Action Comics 963-964 - Superman, Meet Clark Kent.zip	to_parse
562	DC/03. Rebirth/032. Suicide Squad v5 05-08.zip	to_parse
563	DC/03. Rebirth/057. Green Arrow v6 18-20.zip	to_parse
564	DC/03. Rebirth/005. Action Comics v01 - Path of Doom.zip	to_parse
565	DC/03. Rebirth/162. Justice League v4 09.zip	to_parse
566	DC/03. Rebirth/040. Hal Jordan and the Green Lantern Corps v02 - Bottled Light.zip	to_parse
567	DC/03. Rebirth/079. Green Arrow v6 25.zip	to_parse
568	DC/03. Rebirth/088. Superman v4 27-28.zip	to_parse
569	DC/03. Rebirth/104. Batman v3 33-35.zip	to_parse
571	DC/03. Rebirth/143. Batman v3 48-49.zip	to_parse
572	DC/03. Rebirth/053. Trinity v2 07.zip	to_parse
574	DC/03. Rebirth/138. Batman v3 45-47.zip	to_parse
575	DC/03. Rebirth/007. Hal Jordan and the Green Lantern Corps - Rebirth.zip	to_parse
576	DC/03. Rebirth/063. Action Comics 977-978.zip	to_parse
577	DC/03. Rebirth/113. Super Sons of Tomorrow.zip	to_parse
578	DC/03. Rebirth/028. Superman v4 10-11.zip	to_parse
579	DC/03. Rebirth/076. The Flash v5 23-24.zip	to_parse
580	DC/03. Rebirth/189. Heroes in Crisis 01-04.zip	to_parse
581	DC/03. Rebirth/139. Detective Comics v07 - Batmen Eternal.zip	to_parse
582	DC/03. Rebirth/077. Superman v4 v04 - Black Dawn.zip	to_parse
583	DC/03. Rebirth/081. Actions Comics 979-980.zip	to_parse
584	DC/03. Rebirth/141. Detective Comics 982.zip	to_parse
585	DC/03. Rebirth/039. Detective Comics 943-947.zip	to_parse
586	DC/03. Rebirth/047. Nightwing v4 v02 - Back to Bludhaven.zip	to_parse
587	DC/03. Rebirth/118. Superman v4 40-41.zip	to_parse
588	DC/03. Rebirth/132. Hal Jordan and the Green Lantern Corps 42-43.zip	to_parse
589	DC/03. Rebirth/052. Action Comics & Superman v5 - Superman Reborn.zip	to_parse
590	DC/03. Rebirth/078. Super Sons 05.zip	to_parse
591	DC/03. Rebirth/095. All-Star Batman v03 - The First Ally.zip	to_parse
592	DC/03. Rebirth/054. Hal Jordan and the Green Lantern Corps 14-17.zip	to_parse
593	DC/03. Rebirth/174. Superman v01 - The Unity Saga - Phantom Earth.zip	to_parse
594	DC/03. Rebirth/128. Batman & the Signal.zip	to_parse
595	DC/03. Rebirth/004. Superman - Rebirth.zip	to_parse
596	DC/03. Rebirth/062. Suicide Squad v5 11-15.zip	to_parse
597	DC/03. Rebirth/066. Justice League of America v5 05-06.zip	to_parse
598	DC/03. Rebirth/023. Action Comics 965-966.zip	to_parse
599	DC/03. Rebirth/044. Action Comics v03 - Men of Steel.zip	to_parse
600	DC/03. Rebirth/154. Detective Comics 983-987.zip	to_parse
601	DC/03. Rebirth/065. Detective Comics v03 - League of Shadows.zip	to_parse
602	DC/03. Rebirth/164. The Silencer v02 - Hell-iday Road.zip	to_parse
603	DC/03. Rebirth/084. Suicide Squad v5 20.zip	to_parse
604	DC/03. Rebirth/042. Justice League of America - Road to Rebirth.zip	to_parse
605	DC/03. Rebirth/099. Superman v4 31-32.zip	to_parse
606	DC/03. Rebirth/096. Detective Comics 964.zip	to_parse
607	DC/03. Rebirth/185. Detective Comics 994-999.zip	to_parse
608	DC/03. Rebirth/106. Batman v3 Annual 02.zip	to_parse
609	DC/03. Rebirth/175. Catwoman v5 v01 - Copycats.zip	to_parse
611	DC/03. Rebirth/073. Justice League of America v5 07.zip	to_parse
612	DC/03. Rebirth/173. Hawkman v5 07 - Origin.zip	to_parse
613	DC/03. Rebirth/184. Justice League v4 18.zip	to_parse
614	DC/03. Rebirth/163. Mister Miracle v4.zip	to_parse
615	DC/03. Rebirth/134. Adventures of the Super Sons 01-12.zip	to_parse
616	DC/03. Rebirth/080. Suicide Squad v5 16-17.zip	to_parse
617	DC/03. Rebirth/049. Superman v4 017.zip	to_parse
618	DC/03. Rebirth/046. Superman v4 14-16.zip	to_parse
619	DC/03. Rebirth/122. Super Sons 13-14.zip	to_parse
620	DC/03. Rebirth/093. Nightwing v4 26-28.zip	to_parse
621	DC/03. Rebirth/034. Gotham Academy v2 - Second Semester 04.zip	to_parse
622	DC/03. Rebirth/142. Batman - Preludes to the Wedding.zip	to_parse
623	DC/03. Rebirth/181. Justice League Odyssey v01 - The Ghost Sector.zip	to_parse
624	DC/03. Rebirth/022. The Flash v5 09.zip	to_parse
625	DC/03. Rebirth/003. Nightwing - Rebirth.zip	to_parse
626	DC/03. Rebirth/135. DC Nation 00.zip	to_parse
627	DC/03. Rebirth/183. Catwoman v5 07-08.zip	to_parse
628	DC/03. Rebirth/069. Batman v3 023.zip	to_parse
629	DC/03. Rebirth/120. Detective Comics 975.zip	to_parse
630	DC/03. Rebirth/147. The Man of Steel.zip	to_parse
631	DC/03. Rebirth/140. Justice League - No Justice.zip	to_parse
632	DC/03. Rebirth/159. Hawkman v5 v01 - Awakening.zip	to_parse
633	DC/03. Rebirth/146. Plastic Man v5 01-06.zip	to_parse
635	DC/03. Rebirth/176. Action Comics v01 - Invisible Mafia.zip	to_parse
636	DC/03. Rebirth/117. Detective Comics v06 - Fall of the Batmen.zip	to_parse
637	DC/03. Rebirth/129. Superman v4 45.zip	to_parse
638	DC/03. Rebirth/151. Justice League v4 05.zip	to_parse
639	DC/03. Rebirth/015. Superman v4 07 - Our Town.zip	to_parse
640	DC/03. Rebirth/179. Justice League v4 14-16 + Annual 01.zip	to_parse
641	DC/03. Rebirth/060. The Flash v5 20.zip	to_parse
642	DC/03. Rebirth/070. Nightwing v4 21.zip	to_parse
643	DC/03. Rebirth/097. Hal Jordan and the Green Lantern Corps 26-29.zip	to_parse
644	DC/03. Rebirth/083. Action Comics 981-984.zip	to_parse
645	DC/03. Rebirth/187. Detective Comics 1000 - The Deluxe Edition.zip	to_parse
646	DC/03. Rebirth/182. Justice League v4 17.zip	to_parse
647	DC/03. Rebirth/171. Justice League v4 13.zip	to_parse
648	DC/03. Rebirth/068. Super Sons 01-04.zip	to_parse
649	DC/03. Rebirth/168. Justice League & Aquaman - Drowned Earth.zip	to_parse
650	DC/03. Rebirth/019. Suicide Squand v5 - Rebirth + 01-04.zip	to_parse
651	DC/03. Rebirth/055. The Flash v5 18-19.zip	to_parse
652	DC/03. Rebirth/109. Batman v3 36-38.zip	to_parse
653	DC/03. Rebirth/074. Batman v3 24.zip	to_parse
654	DC/03. Rebirth/131. Action Comics 1000.zip	to_parse
655	DC/03. Rebirth/071. Detective Comics 957.zip	to_parse
656	DC/03. Rebirth/072. Hal Jordan and the Green Lantern Corps 18-21.zip	to_parse
657	DC/03. Rebirth/125. The Silencer 01-03.zip	to_parse
658	DC/03. Rebirth/153. Batman v3 51-53.zip	to_parse
659	DC/03. Rebirth/121. Action Comics 999.zip	to_parse
661	DC/03. Rebirth/045. Detective Comics 948-949.zip	to_parse
662	DC/03. Rebirth/091. Detective Comics 963.zip	to_parse
663	DC/03. Rebirth/190. The Flash v5 Annual 02.zip	to_parse
664	DC/03. Rebirth/035. Batman v3 09-13.zip	to_parse
665	DC/03. Rebirth/012. Superman v4 v01 - Son of Superman.zip	to_parse
666	DC/03. Rebirth/192. Heroes in Crisis 05-09.zip	to_parse
667	DC/03. Rebirth/038. All-Star Batman v01 - My Own Worst Enemy.zip	to_parse
668	DC/03. Rebirth/048. Trinity v2 v01 - Better Together.zip	to_parse
669	DC/03. Rebirth/170. Batman v3 - Secret Files.zip	to_parse
670	DC/03. Rebirth/156. Batman v3 54-57.zip	to_parse
671	DC/03. Rebirth/124. Hal Jordan and the Green Lantern Corps 37-41.zip	to_parse
672	DC/03. Rebirth/030. Superman v4 Annual 01.zip	to_parse
673	DC/03. Rebirth/145. The Silencer 04-06.zip	to_parse
674	DC/03. Rebirth/180. The Silencer 013.zip	to_parse
675	DC/03. Rebirth/112. Hal Jordan and the Green Lantern Corps 33-36.zip	to_parse
676	DC/03. Rebirth/157. Justice League v4 06-07.zip	to_parse
677	DC/03. Rebirth/126. Batman v3 44.zip	to_parse
678	DC/03. Rebirth/195. Catwoman v5 Annual 01.zip	to_parse
679	DC/03. Rebirth/155. The Silencer Annual 01.zip	to_parse
680	DC/03. Rebirth/133. Super Sons - Dynomutt Special.zip	to_parse
682	DC/03. Rebirth/021. Green Arrow v6 08-09.zip	to_parse
683	DC/03. Rebirth/064. Nightwing v4 16-20 - Nightwing Must Die.zip	to_parse
684	DC/03. Rebirth/144. Hal Jordan and the Green Lantern Corps 044-47.zip	to_parse
685	DC/03. Rebirth/037. The Flash v5 13.zip	to_parse
686	DC/03. Rebirth/075. Green Arrow v6 21-24.zip	to_parse
687	DC/03. Rebirth/105. Action Comics 992.zip	to_parse
688	DC/03. Rebirth/050. Green Arrow v6 v03 - Emerald Outlaw.zip	to_parse
689	DC/03. Rebirth/018. The Flash v5 01-08 - Lightning Strikes Twice.zip	to_parse
690	DC/03. Rebirth/149. Justice League v4 01-04.zip	to_parse
691	DC/03. Rebirth/103. Detective Comics v05 - A Lonely Place of Living.zip	to_parse
692	DC/03. Rebirth/006. Green Arrow v6 - Rebirth + 01-05 - The Death and Life of Oliver Queen.zip	to_parse
693	DC/03. Rebirth/085. Nightwing v4 22-25 - Blockbuster.zip	to_parse
694	DC/03. Rebirth/010. Batman v3 v01 - I Am Gotham.zip	to_parse
695	DC/03. Rebirth/100. Super Sons v02 - Planet of the Capes.zip	to_parse
696	DC/03. Rebirth/011. Nightwing v4 01-04 - Better than Batman.zip	to_parse
698	DC/03. Rebirth/090. Gotham Academy v2 - Second Semester 09-12 - The Ballad of Olive Silverlock.zip	to_parse
699	DC/03. Rebirth/127. Superman v4 42-44.zip	to_parse
700	DC/03. Rebirth/059. Justice League of America v5 - Rebirth + 01-04.zip	to_parse
701	DC/03. Rebirth/107. Super Sons Annual 01.zip	to_parse
702	DC/03. Rebirth/116. Swamp Thing Winter Special.zip	to_parse
703	DC/03. Rebirth/101. Hal Jordan and the Green Lantern Corps 30-31.zip	to_parse
704	DC/03. Rebirth/137. Superman v4 Special.zip	to_parse
705	DC/03. Rebirth/025. Nightwing v4 07-08.zip	to_parse
706	DC/03. Rebirth/014. Night of the Monster Men.zip	to_parse
707	DC/03. Rebirth/029. Green Arrow v6 10-11.zip	to_parse
708	DC/03. Rebirth/082. Suicide Squad v5 18-19.zip	to_parse
709	DC/03. Rebirth/115. Batman v3 39-40.zip	to_parse
710	DC/03. Rebirth/009. Justice League - Rebirth.zip	to_parse
711	DC/03. Rebirth/087. Hal Jordan and the Green Lantern Corps 22-25.zip	to_parse
712	DC/03. Rebirth/092. Action Comics 985-986.zip	to_parse
713	DC/03. Rebirth/008. Green Lanterns - Rebirth.zip	to_parse
714	DC/03. Rebirth/036. Superman v4 12-13.zip	to_parse
715	DC/03. Rebirth/160. Justice League v4 08.zip	to_parse
716	DC/03. Rebirth/114. Superman v4 39.zip	to_parse
717	DC/03. Rebirth/172. Batman v3 Annual 03.zip	to_parse
718	DC/03. Rebirth/094. Superman v4 29-30.zip	to_parse
719	DC/03. Rebirth/041. Suicide Squad.zip	to_parse
720	DC/03. Rebirth/086. Flash v5 25-27.zip	to_parse
721	DC/03. Rebirth/148. Batman v3 50.zip	to_parse
722	DC/03. Rebirth/002. The Flash - Rebirth.zip	to_parse
723	DC/03. Rebirth/089. Detective Comics 958-962.zip	to_parse
724	DC/03. Rebirth/016. Green Arrow v6 06-07 - Sins of the Mother & The Killing Time.zip	to_parse
725	DC/03. Rebirth/031. Batman v3 Annual 01.zip	to_parse
726	DC/03. Rebirth/013. Detective Comics v01 - Rise of the Batmen.zip	to_parse
727	DC/03. Rebirth/058. Gotham Academy v2 - Second Semester 05-08.zip	to_parse
728	DC/03. Rebirth/033. The Flash v5 10-12.zip	to_parse
729	DC/03. Rebirth/001. DC Universe - Rebirth.zip	to_parse
731	DC/03. Rebirth/119. Action Comics 993-998.zip	to_parse
732	DC/03. Rebirth/165. Batman v3 - Secret Files.zip	to_parse
733	DC/03. Rebirth/110. Metal prelude - Recap from previous Batman.zip	to_parse
734	DC/03. Rebirth/051. The Flash v5 14-17.zip	to_parse
735	DC/03. Rebirth/043. Batman v3 14-15.zip	to_parse
736	DC/03. Rebirth/En cours/Doomsday Clock 01-12/Doomsday Clock 01-12.zip	to_parse
737	DC/02. New 52/105. Animal Man v2 21-29.zip	to_parse
738	DC/02. New 52/135. Futures End 00-17.zip	to_parse
739	DC/02. New 52/166. Superman v3 32-40 - The Men of Tomorrow.zip	to_parse
740	DC/02. New 52/184. The Flash v4 48-52.zip	to_parse
741	DC/02. New 52/012. Green Arrow v5 00.zip	to_parse
742	DC/02. New 52/192. Batman - Superman 21-24.zip	to_parse
743	DC/02. New 52/172. Robin Son of Batman v01 - Year of Blood.zip	to_parse
744	DC/02. New 52/003. Detective Comics v2 00.zip	to_parse
745	DC/02. New 52/224. Superman - Lois & Clark.zip	to_parse
746	DC/02. New 52/128. Batman Eternal 15-20.zip	to_parse
747	DC/02. New 52/148. Arkham Manor 01-03.zip	to_parse
749	DC/02. New 52/115. The Flash 30-40 + Annual 03 + Futures End.zip	to_parse
750	DC/02. New 52/134. Detective Comics v2 35-36.zip	to_parse
751	DC/02. New 52/116. Sinestro 01-05.zip	to_parse
752	DC/02. New 52/056. Larfleeze 07-12.zip	to_parse
753	DC/02. New 52/133. Batman v2 34.zip	to_parse
754	DC/02. New 52/112. Justice League v2 31-34.zip	to_parse
755	DC/02. New 52/106. Talon 12-17.zip	to_parse
756	DC/02. New 52/151. Secret Origins 10.zip	to_parse
758	DC/02. New 52/153. Arkham Manor 04-06.zip	to_parse
759	DC/02. New 52/127. Green Arrow v5 32-34.zip	to_parse
760	DC/02. New 52/143. Grayson 01-03.zip	to_parse
761	DC/02. New 52/225. Batman v2 52.zip	to_parse
762	DC/02. New 52/059. Green Lantern - New Guardians 21-22.zip	to_parse
763	DC/02. New 52/199. Black Canary v4 01-09 - Kicking and Screaming.zip	to_parse
764	DC/02. New 52/035. Wonder Woman v4 01-06.zip	to_parse
765	DC/02. New 52/138. Futures End Tie-Ins - Batman-Superman + Booster Gold + Grayson + Swamp Thing.zip	to_parse
766	DC/02. New 52/162. Red Lanterns 38-40.zip	to_parse
767	DC/02. New 52/051. Rise of the Third Army.zip	to_parse
768	DC/02. New 52/126. Batman Eternal 01-14.zip	to_parse
769	DC/02. New 52/085. Red Lanterns 25-26.zip	to_parse
770	DC/02. New 52/144. Batman Eternal 29-30.zip	to_parse
771	DC/02. New 52/123. Detective Comics v2 Annual 03.zip	to_parse
772	DC/02. New 52/120. Superman - Doomed.cbz	to_parse
773	DC/02. New 52/130. Green Lantern Corps v3 28-30.zip	to_parse
774	DC/02. New 52/171. Gotham by Midnight 06 + Annual 01.zip	to_parse
776	DC/02. New 52/183. Superman-Wonder Woman 18-21.zip	to_parse
777	DC/02. New 52/227.b Darkseid War Part II - Power of the Gods.zip	to_parse
778	DC/02. New 52/188. Martian Manhunter v4.zip	to_parse
779	DC/02. New 52/227.c Darkseid War Part III - Justice League v2 46-50 + Special.zip	to_parse
780	DC/02. New 52/101. Green Arrow v5 25-31.zip	to_parse
781	DC/02. New 52/071. The Flash v4 20-24 + Villain Month + Annual 02.zip	to_parse
782	DC/02. New 52/198. Grayson 12 + Annual 02.zip	to_parse
783	DC/02. New 52/185. Midnighter 05-07.zip	to_parse
784	DC/02. New 52/216. Secret Six v4 11-14.zip	to_parse
785	DC/02. New 52/208. Batman and Robin Eternal 01-25.zip	to_parse
786	DC/02. New 52/211. Robin War.zip	to_parse
787	DC/02. New 52/061. Rot World.zip	to_parse
788	DC/02. New 52/019. Detective Comics v2 01-05 - Faces of Death.zip	to_parse
789	DC/02. New 52/122. Batman and Robin v2 v07 - Robin Rises.zip	to_parse
790	DC/02. New 52/042. Animal Man v2 09-11 + Annual 01.zip	to_parse
791	DC/02. New 52/202. Catwoman v4 43-46 - Inheritance.zip	to_parse
792	DC/02. New 52/095. Green Lantern - New Guardians Annual 02 + 31-34 - God Killers.zip	to_parse
793	DC/02. New 52/062. Batman and Robin v2 v02 - Pearl.zip	to_parse
794	DC/02. New 52/026. Green Lantern - New Guardians 01-05.zip	to_parse
795	DC/02. New 52/124. Secret Origins 08.zip	to_parse
796	DC/02. New 52/109. Forever Evil - Blight.zip	to_parse
797	DC/02. New 52/102. Gothtopia.zip	to_parse
798	DC/02. New 52/028. Green Lantern - New Guardians 06-07.zip	to_parse
799	DC/02. New 52/067. Talon 01-04.zip	to_parse
800	DC/02. New 52/117. Red Daughter of Krypton.zip	to_parse
801	DC/02. New 52/160. Gotham Academy v01 - Welcome to Gotham Academy.zip	to_parse
802	DC/02. New 52/212. Gotham Academy v03 - Yearbook.zip	to_parse
803	DC/02. New 52/014. Animal Man v2 01-05.zip	to_parse
804	DC/02. New 52/065. The Flash v4 11-17 + Annual 01.zip	to_parse
806	DC/02. New 52/203. Gotham by Midnight 07-12 - Rest in Peace.zip	to_parse
807	DC/02. New 52/074. Green Lantern v5 23.zip	to_parse
808	DC/02. New 52/197.a Batman v2 v08 - Superheavy.zip	to_parse
809	DC/02. New 52/119. Superman-Wonder Woman 05-06.zip	to_parse
810	DC/02. New 52/179. Grayson 09-11.zip	to_parse
811	DC/02. New 52/052. Wrath of the First Lantern.zip	to_parse
812	DC/02. New 52/006. Action Comics 00.zip	to_parse
813	DC/02. New 52/170. Convergence.zip	to_parse
814	DC/02. New 52/145. Detective Comics v2 37-40.zip	to_parse
815	DC/02. New 52/214. We Are Robin 08-12 - Jokers.zip	to_parse
816	DC/02. New 52/189. Green Lantern v5 - The Lost Army.zip	to_parse
817	DC/02. New 52/093. Talon 05-11.zip	to_parse
818	DC/02. New 52/193. Catwoman v4 41-42.zip	to_parse
819	DC/02. New 52/177. Sinestro 14.zip	to_parse
820	DC/02. New 52/154. Batman Eternal 36.zip	to_parse
821	DC/02. New 52/090. Animal Man v2 Annual 02.zip	to_parse
822	DC/02. New 52/084. Batman v2 18-20.zip	to_parse
823	DC/02. New 52/073. Green Lantern - New Guardians 23 + 23.1 Relic.zip	to_parse
824	DC/02. New 52/088. Superman Wonder Woman 01-04 - Power Couple.zip	to_parse
825	DC/02. New 52/096. Batwoman v2 21.zip	to_parse
826	DC/02. New 52/013. Secret Origins 01-07 + 09 + 11.zip	to_parse
827	DC/02. New 52/222. Grayson 16-20 + Annual 03 - Spyral's End.zip	to_parse
828	DC/02. New 52/182. Sinestro 15-21.zip	to_parse
829	DC/02. New 52/206. We Are Robin 05-06.zip	to_parse
830	DC/02. New 52/176. Gotham Academy v02 - Calamity.zip	to_parse
832	DC/02. New 52/118. Green Lantern v5 29-30.zip	to_parse
833	DC/02. New 52/060. Swamp Thing v5 10-11.zip	to_parse
834	DC/02. New 52/072. Red Lanterns 21-22.zip	to_parse
835	DC/02. New 52/054. Wonder Woman v4 11-12.zip	to_parse
836	DC/02. New 52/139. Futures End 28-48.zip	to_parse
837	DC/02. New 52/157. Batman Eternal 37-42.zip	to_parse
838	DC/02. New 52/205. Superman - Savage Dawn.zip	to_parse
840	DC/02. New 52/111. Forever Evil - Aftermath.zip	to_parse
841	DC/02. New 52/005. Nightwing v3 00.zip	to_parse
842	DC/02. New 52/180. The Omega Men - The End is Here.zip	to_parse
843	DC/02. New 52/004. Swamp Thing v5 00.zip	to_parse
844	DC/02. New 52/021. Detective Comics v2 05-08.zip	to_parse
845	DC/02. New 52/037. The Flash v4 06-08.zip	to_parse
846	DC/02. New 52/187. Action Comics v2 41-44.zip	to_parse
848	DC/02. New 52/163. Green Lantern v5 39-40.zip	to_parse
849	DC/02. New 52/045. Green Lantern v5 06-10.zip	to_parse
850	DC/02. New 52/204. Superman v3 45-46.zip	to_parse
851	DC/02. New 52/221. Robin Son of Batman v02 - Dawn of the Demons.zip	to_parse
852	DC/02. New 52/103. Batwoman v2 v05 - Webs.zip	to_parse
853	DC/02. New 52/140. Batman Eternal 21-25.zip	to_parse
854	DC/02. New 52/197.b Batman v2 Annual 04.zip	to_parse
855	DC/02. New 52/011. Talon 00.zip	to_parse
856	DC/02. New 52/087. Green Lantern v5 23.2-23.3 - Villain's Month.zip	to_parse
857	DC/02. New 52/007. Action Comics v01 - World Against Superman.zip	to_parse
858	DC/02. New 52/015. Swamp Thing v5 01-03.zip	to_parse
859	DC/02. New 52/099. Joker's Daughter.zip	to_parse
860	DC/02. New 52/041. Wonder Woman v4 08-10.zip	to_parse
861	DC/02. New 52/125. Batman v2 28 - Batman Eternal Teaser.zip	to_parse
862	DC/02. New 52/064. Nightwing v3 10-12.zip	to_parse
863	DC/02. New 52/046. Green Lantern - New Guardians 08-10.zip	to_parse
864	DC/02. New 52/100. Batwoman v2 22-24.zip	to_parse
865	DC/02. New 52/092. Wonder Woman v4 23.2 (First Born) + 24-35.zip	to_parse
866	DC/02. New 52/053. Larfleeze 01-06.zip	to_parse
867	DC/02. New 52/043. Nightwing v3 06-07.zip	to_parse
869	DC/02. New 52/195. Detective Comics v2 41-44 - Blood of Heroes.zip	to_parse
870	DC/02. New 52/034. Batwoman v2 12-17 - World's Finest.zip	to_parse
871	DC/02. New 52/181. Divergence + Superman 41-44.zip	to_parse
872	DC/02. New 52/017. Batwoman v2 01-05 - Hydrology.zip	to_parse
873	DC/02. New 52/226. Green Lanterns Corps - Edge of Oblivion 01-06.zip	to_parse
874	DC/02. New 52/219. Batman and Robin Eternal 26.zip	to_parse
875	DC/02. New 52/040. The Flash v4 09-10.zip	to_parse
876	DC/02. New 52/033. The Flash v4 04-05.zip	to_parse
877	DC/02. New 52/068. The Flash v4 18-19.zip	to_parse
878	DC/02. New 52/031. The Flash v4 01-03.zip	to_parse
879	DC/02. New 52/070. Animal Man v2 20.zip	to_parse
880	DC/02. New 52/032. Animal Man v2 07-08.zip	to_parse
881	DC/02. New 52/190. We Are Robin 01-04 - The Vigilante Business.zip	to_parse
882	DC/02. New 52/029. Green Lantern v5 03-05.zip	to_parse
883	DC/02. New 52/186. Green Lantern v5 41-44.zip	to_parse
884	DC/02. New 52/104. Superman - Lois Lane.zip	to_parse
885	DC/02. New 52/158. Secret Six v4 01-02.zip	to_parse
886	DC/02. New 52/083. Superman Unchained.zip	to_parse
887	DC/02. New 52/075. Red Lanterns 23.zip	to_parse
888	DC/02. New 52/174. Sinestro 13.zip	to_parse
889	DC/02. New 52/196. Green Lantern v5 Annual 04 + 45-52.zip	to_parse
890	DC/02. New 52/207. Detective Comics v2 45-46.zip	to_parse
891	DC/02. New 52/194. Sinestro 22-23.zip	to_parse
892	DC/02. New 52/137. Futures End 18-27.zip	to_parse
894	DC/02. New 52/142. Batman Eternal 26-28.zip	to_parse
895	DC/02. New 52/113. Green Lantern v5 23.4 - Sinestro.zip	to_parse
896	DC/02. New 52/121. Batman and Robin v2 v06 - The Hunt for Robin.zip	to_parse
897	DC/02. New 52/210. Grayson 13-14 - A Ghost in the Tomb.zip	to_parse
898	DC/02. New 52/089. Batwoman v2 18.zip	to_parse
899	DC/02. New 52/055. Swamp Thing v5 04-09.zip	to_parse
900	DC/02. New 52/039. Batman and Robin v2 v01 - Born to Kill.zip	to_parse
901	DC/02. New 52/057. Green Lantern Corps v3 21.zip	to_parse
902	DC/02. New 52/167. Batman v2 - Endgame (from issues).zip	to_parse
903	DC/02. New 52/150. Catwoman v4 35-40 + Annual 02 - Keeper of the Castle.zip	to_parse
904	DC/02. New 52/024. Red Lantern 01-02.zip	to_parse
905	DC/02. New 52/136. Green Arrow - Futures End.zip	to_parse
906	DC/02. New 52/200. Midnighter 08-12 - Hard.zip	to_parse
907	DC/02. New 52/191. Batman v2 41.zip	to_parse
908	DC/02. New 52/020. The Dark Knight v2 01-05 - Knight v2 Terrors.zip	to_parse
909	DC/02. New 52/209. Secret Six v4 07-10.zip	to_parse
910	DC/02. New 52/168. Gotham by Midnight 01-05 - We do not Sleep.zip	to_parse
911	DC/02. New 52/038. Wonder Woman v4 07.zip	to_parse
912	DC/02. New 52/077. Green Lantern Corps v3 22-23.zip	to_parse
913	DC/02. New 52/110. Forever Evil - Part 2.zip	to_parse
914	DC/02. New 52/147. Grayson 04-08.zip	to_parse
915	DC/02. New 52/146. Batman Eternal 31-34.zip	to_parse
916	DC/02. New 52/108. Forever Evil - Part 1.zip	to_parse
917	DC/02. New 52/218. Batman v2 v09 - Bloom.zip	to_parse
919	DC/02. New 52/227.a Darkseid War Part I - Justice League v2 40-45.zip	to_parse
920	DC/02. New 52/025. Green Lantern v5 01-02.zip	to_parse
921	DC/02. New 52/213. Catwoman v4 47-50 - Run Like Hell.zip	to_parse
922	DC/02. New 52/094. Batwoman v2 19-20.zip	to_parse
923	DC/02. New 52/149. Green Lantern v5 38.zip	to_parse
924	DC/02. New 52/050. Green Lantern v5 11-12.zip	to_parse
925	DC/02. New 52/023. Batwoman v2 06-11 + 00 - To Drown the World.zip	to_parse
926	DC/02. New 52/066. Animal Man v2 19.zip	to_parse
927	DC/02. New 52/076. Wonder Woman v4 19-21.zip	to_parse
928	DC/02. New 52/107. Trinity War.zip	to_parse
929	DC/02. New 52/018. Green Lantern Corps v3 01-07 - Fearsome.zip	to_parse
931	DC/02. New 52/161. Justice League v2 35-39.zip	to_parse
932	DC/02. New 52/228. The Final Days of Superman.zip	to_parse
933	DC/02. New 52/097. Green Lantern Universe Interlude.zip	to_parse
934	DC/02. New 52/169. The Multiversity - Deluxe Edition.zip	to_parse
935	DC/02. New 52/063. Wonder Woman v4 13-18.zip	to_parse
936	DC/02. New 52/048. Red Lanterns 10-12.zip	to_parse
937	DC/02. New 52/131. Uprising.zip	to_parse
938	DC/02. New 52/215. Detective Comics v2 48-50 - Gordon at War.zip	to_parse
939	DC/02. New 52/010. Animal Man v2 00.zip	to_parse
940	DC/02. New 52/178. Midnighter 01-04.zip	to_parse
941	DC/02. New 52/172. Secret Six v4 03-06.zip	to_parse
942	DC/02. New 52/175. The Flash 41-47 + Annual 04.zip	to_parse
943	DC/02. New 52/098. Green Arrow v5 17-24.zip	to_parse
945	DC/02. New 52/044. Justice League v2 00.zip	to_parse
946	DC/02. New 52/201. Action Comics v2 45-47.zip	to_parse
947	DC/02. New 52/081. Lights Out.zip	to_parse
948	DC/02. New 52/155. Green Lantern Corps v3 38-40.zip	to_parse
949	DC/02. New 52/132. Uprising Aftermath.zip	to_parse
950	DC/02. New 52/165. Green Lantern - New Guardians 38-40.zip	to_parse
951	DC/02. New 52/152. Batman Eternal 35.zip	to_parse
952	DC/02. New 52/002. The Dark Knight v2 00.zip	to_parse
953	DC/02. New 52/156. Grayson Annual 01.zip	to_parse
954	DC/02. New 52/078. Wonder Woman v4 22-23.zip	to_parse
955	DC/02. New 52/036. Nightwing v3 05.zip	to_parse
956	DC/02. New 52/069. Death of the Family.zip	to_parse
957	DC/02. New 52/001. Wonder Woman v4 v4 00.zip	to_parse
958	DC/02. New 52/082. Green Lantern v5 25-26.zip	to_parse
959	DC/02. New 52/016. Animal Man v2 06.zip	to_parse
960	DC/02. New 52/008. The Flash v4 00.zip	to_parse
961	DC/02. New 52/141. Godhead.zip	to_parse
962	DC/02. New 52/079. Batman and Robin v2 Annual 01.zip	to_parse
963	DC/02. New 52/027. Red Lanterns 03.zip	to_parse
964	DC/02. New 52/159. Batman Eternal 43-52.zip	to_parse
965	DC/02. New 52/022. Nightwing v3 01-04 - Traps and Trapezes.zip	to_parse
966	DC/02. New 52/030. Red Lanterns 04-09.zip	to_parse
967	DC/02. New 52/229. Justice League v2 51-52.zip	to_parse
968	DC/02. New 52/058. Green Lantern v5 21-22.zip	to_parse
970	DC/01. Crisis to crisis/237. The Road to Flashpoint.zip	to_parse
971	DC/01. Crisis to crisis/184. Batman R.I.P. - Part I (from issues).zip	to_parse
972	DC/01. Crisis to crisis/151. DCU Infinite Holiday Special (The Flash).zip	to_parse
973	DC/01. Crisis to crisis/128. Day of Vengeance 01-06.zip	to_parse
974	DC/01. Crisis to crisis/229. Batman And Robin 26.zip	to_parse
975	DC/01. Crisis to crisis/136. JSA 76-81 - Mixed Signals.zip	to_parse
976	DC/01. Crisis to crisis/090. Hawkman v4 01-06.zip	to_parse
977	DC/01. Crisis to crisis/193. Batman - Battle for the Cowl - Bonus (from issues).zip	to_parse
978	DC/01. Crisis to crisis/008. Crisis on Multiple Earths v06.zip	to_parse
979	DC/01. Crisis to crisis/208. Secret Six v02 - Money for Murder.zip	to_parse
980	DC/01. Crisis to crisis/037. Batman - Bride of the Demon.zip	to_parse
981	DC/01. Crisis to crisis/020. Batman - Haunted Knight.zip	to_parse
983	DC/01. Crisis to crisis/204. Gotham City Sirens - Book One.zip	to_parse
984	DC/01. Crisis to crisis/101. Superman - Birthright.zip	to_parse
985	DC/01. Crisis to crisis/007. Crisis on Multiple Earths v05.zip	to_parse
986	DC/01. Crisis to crisis/040. Superman - Funeral for a Friend.zip	to_parse
987	DC/01. Crisis to crisis/179. Countdown Specials - The Search for Ray Palmer 01-06.zip	to_parse
988	DC/01. Crisis to crisis/209. Green Lantern v4 36-38 + Final Crisis Special - Rage of the Red Lanterns.zip	to_parse
989	DC/01. Crisis to crisis/061. Batman - Road to No Man's Land v01 - Aftershock.zip	to_parse
990	DC/01. Crisis to crisis/187. Legion of Three Worlds 01-05.zip	to_parse
991	DC/01. Crisis to crisis/194. Secret Six v01 - Villains United.zip	to_parse
992	DC/01. Crisis to crisis/223. Brightest Day Part I (from issues) - BD 00-05 + Tie-ins.zip	to_parse
993	DC/01. Crisis to crisis/066. JLA 28-31 - Crisis Time Five.zip	to_parse
994	DC/01. Crisis to crisis/170. Green Lantern Corps - Ring Quest.zip	to_parse
995	DC/01. Crisis to crisis/189. Batman 701-702 - Final Crisis - The Missing Chapters.zip	to_parse
996	DC/01. Crisis to crisis/182. Death of the New Gods 01-08.zip	to_parse
997	DC/01. Crisis to crisis/001. Crisis on Multiple Earths - The Team-ups v01 (from issues).zip	to_parse
998	DC/01. Crisis to crisis/068. Batman - No Man's Land v01.zip	to_parse
999	DC/01. Crisis to crisis/171. Green Lantern v4 29-35 - Secret Origin.zip	to_parse
1000	DC/01. Crisis to crisis/046. Batman - The Crusade v02.zip	to_parse
1001	DC/01. Crisis to crisis/219. The Return of Bruce Wayne 01-06 + Tie-ins.zip	to_parse
1002	DC/01. Crisis to crisis/176. JSA-JLA cross-over - The Lightning Saga (from issues).zip	to_parse
1003	DC/01. Crisis to crisis/067. Batman - Road to No Man's Land v02.zip	to_parse
1004	DC/01. Crisis to crisis/195. The Flash - Rebirth 01-06.zip	to_parse
1005	DC/01. Crisis to crisis/014. Crisis on Infinite Earths - Bonus.zip	to_parse
1006	DC/01. Crisis to crisis/027. Animal Man v01 - Animal Man.zip	to_parse
1007	DC/01. Crisis to crisis/129. JSA 68-75 - Black Vengeance.zip	to_parse
1008	DC/01. Crisis to crisis/143. Birds of Prey 86-90 - Perfect Pitch.zip	to_parse
1009	DC/01. Crisis to crisis/019. Green Arrow Year One.zip	to_parse
1010	DC/01. Crisis to crisis/059. JLA 10-15 - Rock of ages.zip	to_parse
1011	DC/01. Crisis to crisis/148. Green Arrow v3 60-65 - Crawling from the Wreckage (One Year Later).zip	to_parse
1012	DC/01. Crisis to crisis/124. Batman - Under the Hood.zip	to_parse
1014	DC/01. Crisis to crisis/055. Starman v01 - Sins of the Father.zip	to_parse
1015	DC/01. Crisis to crisis/010. Swamp Thing v01 - Saga of the Swamp Thing.zip	to_parse
1016	DC/01. Crisis to crisis/131. Rann-Thanagar War 01-06.zip	to_parse
1017	DC/01. Crisis to crisis/203. Batman - Long Shadows.zip	to_parse
1019	DC/01. Crisis to crisis/130. Adam Strange - Planet Heist 01-06.zip	to_parse
1020	DC/01. Crisis to crisis/216. Blackest Night Part IV (from issues) - BN 07-08 + Tie-ins.zip	to_parse
1021	DC/01. Crisis to crisis/222. Batman the Return.zip	to_parse
1022	DC/01. Crisis to crisis/086. JLA & JSA - Virtue and Vice.cbz	to_parse
1023	DC/01. Crisis to crisis/115. JLA 107-114 + Secret Files and Origin - Syndicate Rules.zip	to_parse
1024	DC/01. Crisis to crisis/085. Green Arrow v03 - The Archer's Quest.zip	to_parse
1025	DC/01. Crisis to crisis/078. Superman - Emperor Joker.zip	to_parse
1026	DC/01. Crisis to crisis/228. Batman and Robin v04 - Dark Knight vs. White Knight.zip	to_parse
1027	DC/01. Crisis to crisis/081. Green Arrow v01  - Quiver.zip	to_parse
1028	DC/01. Crisis to crisis/198. Batman 687 - Batman Reborn Prelude.zip	to_parse
1029	DC/01. Crisis to crisis/153. Outsiders v3 34-41 - The Good Fight (One Year Later).zip	to_parse
1030	DC/01. Crisis to crisis/205. Action Comics 865 + World's Finest v4 01-04.zip	to_parse
1031	DC/01. Crisis to crisis/094. Teen Titans & Young Justice - Graduation Day (from issues).zip	to_parse
1032	DC/01. Crisis to crisis/006. Crisis on Multiple Earths v04.zip	to_parse
1033	DC/01. Crisis to crisis/224. Brightest Day Part II (from issues) - BD 06-12 + Tie-ins.zip	to_parse
1034	DC/01. Crisis to crisis/049. Showcase '94 10 - Knightfall Aftermath.cbz	to_parse
1035	DC/01. Crisis to crisis/002. Crisis on Multiple Earths - The Team-ups v02 (from issues).zip	to_parse
1036	DC/01. Crisis to crisis/135. Return of Donna Troy 01-04.zip	to_parse
1037	DC/01. Crisis to crisis/146. Detective Comics & Batman - Face the Face (One Year Later) - The Deluxe Edition.zip	to_parse
1038	DC/01. Crisis to crisis/126. Villains United 01-06.zip	to_parse
1039	DC/01. Crisis to crisis/062. DC One Million Part I (from issues).zip	to_parse
1040	DC/01. Crisis to crisis/080. Superman - President Luthor.zip	to_parse
1041	DC/01. Crisis to crisis/043. Batman - Sword of Azrael 01-04.zip	to_parse
1042	DC/01. Crisis to crisis/169. Sinestro Corps War - Part II (from issues).zip	to_parse
1043	DC/01. Crisis to crisis/099. Batman 626-630 - As the Crow Flies.zip	to_parse
1044	DC/01. Crisis to crisis/145. Infinite Crisis + Companion (from issues).zip	to_parse
1045	DC/01. Crisis to crisis/191. Batman - Last Rites (from issues).zip	to_parse
1047	DC/01. Crisis to crisis/177. Justice League of America v2 13-16 + Wedding Special - Injustice League Unlimited.zip	to_parse
1048	DC/01. Crisis to crisis/113. Adventures of Superman 625-632 - Unconventional Warfare.zip	to_parse
1049	DC/01. Crisis to crisis/168. Sinestro Corps War - Part I (from issues).zip	to_parse
1050	DC/01. Crisis to crisis/079. Batman - New Gotham v01.zip	to_parse
1051	DC/01. Crisis to crisis/215. Blackest Night Part III (from issues) - BN 05-06 + Tie-ins.zip	to_parse
1052	DC/01. Crisis to crisis/013. DC Universe by Alan Moore.zip	to_parse
1053	DC/01. Crisis to crisis/185.b Batman R.I.P. - version courte.zip	to_parse
1054	DC/01. Crisis to crisis/218. Batman and Robin v02 - Batman vs. Robin.zip	to_parse
1055	DC/01. Crisis to crisis/123. Birds of Prey 76-85 - The Battle Within.zip	to_parse
1056	DC/01. Crisis to crisis/077. JLA 43-46 - Tower of Babel.zip	to_parse
1057	DC/01. Crisis to crisis/200. Detective Comics 854-860 - Batwoman Elegy.zip	to_parse
1058	DC/01. Crisis to crisis/003. Crisis on Multiple Earths v01.zip	to_parse
1059	DC/01. Crisis to crisis/039. Superman - The Death of Superman.zip	to_parse
1060	DC/01. Crisis to crisis/226. Brightest Day Part IV (from issues) - BD 15-24 + Tie-ins.zip	to_parse
1061	DC/01. Crisis to crisis/134. Prelude to Infinite Crisis.zip	to_parse
1062	DC/01. Crisis to crisis/202. Red Robin 01-05 - The Grail.zip	to_parse
1063	DC/01. Crisis to crisis/160. Robin v4 148-153 - Wanted (One Year Later).zip	to_parse
1064	DC/01. Crisis to crisis/048. Batman - Knight's End.zip	to_parse
1065	DC/01. Crisis to crisis/103. Batman - Death and the Maidens.zip	to_parse
1066	DC/01. Crisis to crisis/235. War of the Green Lanterns (from issues).zip	to_parse
1067	DC/01. Crisis to crisis/097. Gotham Central v02 - Jokers and Madmen.zip	to_parse
1068	DC/01. Crisis to crisis/197. Milestone Forever 01-02.zip	to_parse
1069	DC/01. Crisis to crisis/201. Hush Money.zip	to_parse
1070	DC/01. Crisis to crisis/137. Supergirl v01 - Power.zip	to_parse
1071	DC/01. Crisis to crisis/167. Black Adam - The Dark Age 01-06.zip	to_parse
1072	DC/01. Crisis to crisis/060. Batman - Cataclysm.zip	to_parse
1073	DC/01. Crisis to crisis/122. The O.M.A.C. Project 04-06.zip	to_parse
1074	DC/01. Crisis to crisis/236. Batman - Gates of Gotham.zip	to_parse
1075	DC/01. Crisis to crisis/154. Justice Society of America v3 01-04 - The Next Age (One Year Later).zip	to_parse
1077	DC/01. Crisis to crisis/093. Batman - Arkham Asylum - Living Hell.zip	to_parse
1078	DC/01. Crisis to crisis/030.f Swamp Thing v06 - Reunion.zip	to_parse
1079	DC/01. Crisis to crisis/041. Superman - Reign of the Supermen.zip	to_parse
1080	DC/01. Crisis to crisis/230. Batman Incorporated v1 - The Deluxe Edition.zip	to_parse
1081	DC/01. Crisis to crisis/070. Batman - Harley Quinn.zip	to_parse
1082	DC/01. Crisis to crisis/022. Nightwing v2 101-106 - Year One.zip	to_parse
1083	DC/01. Crisis to crisis/084. Green Arrow v02 - Sounds of Violence.zip	to_parse
1084	DC/01. Crisis to crisis/147.Nightwing v2 118-122 - Brothers in Blood (One Year Later).zip	to_parse
1085	DC/01. Crisis to crisis/087. Batman - Bruce Wayne - Murderer.zip	to_parse
1087	DC/01. Crisis to crisis/032. Batman - The Cult 01-04.zip	to_parse
1088	DC/01. Crisis to crisis/015. Swamp Thing v04 - A Murder of Crows.zip	to_parse
1089	DC/01. Crisis to crisis/207. Batman 692-699 - Life after death.zip	to_parse
1090	DC/01. Crisis to crisis/162. Fifty Two v01.zip	to_parse
1091	DC/01. Crisis to crisis/112. Manhunter v3 01-05 - Street Justice.zip	to_parse
1092	DC/01. Crisis to crisis/117. Green Lantern Corps - Recharge 01-05.zip	to_parse
1093	DC/01. Crisis to crisis/089. Batman - Hush.zip	to_parse
1094	DC/01. Crisis to crisis/174.a The Resurrection of Ra's Al Ghul.zip	to_parse
1095	DC/01. Crisis to crisis/149. Green Arrow v3 66-75 - Road to Jericho (One Year Later).zip	to_parse
1096	DC/01. Crisis to crisis/110. Identity Crisis.zip	to_parse
1097	DC/01. Crisis to crisis/016. The Man Who Laughs.zip	to_parse
1098	DC/01. Crisis to crisis/239. Flashpoint Part I (from issues) - FP 01-03 + Tie-Ins.zip	to_parse
1099	DC/01. Crisis to crisis/119. Teen Titans v3 16-23 + Legion Special - The Future is now.zip	to_parse
1100	DC/01. Crisis to crisis/012. Swamp Thing v03 - The Curse.zip	to_parse
1101	DC/01. Crisis to crisis/138. JSA Classified 01-04 - Power Trip.zip	to_parse
1103	DC/01. Crisis to crisis/091. Batman-Superman-Wonder Woman - Trinity.zip	to_parse
1104	DC/01. Crisis to crisis/095. Teen Titans v3 01-07 - A Kid's Game.zip	to_parse
1105	DC/01. Crisis to crisis/104. Batman - War Games v01.zip	to_parse
1106	DC/01. Crisis to crisis/141. Captain Atom - Armageddon 01-09.zip	to_parse
1107	DC/01. Crisis to crisis/133.a Teen Titans v3 + Outsiders v3 - The Insiders (from issues).zip	to_parse
1108	DC/01. Crisis to crisis/044. Batman - Prelude to Knightfall.zip	to_parse
1109	DC/01. Crisis to crisis/009. Crisis on Multiple Earths v07 (from issues).zip	to_parse
1110	DC/01. Crisis to crisis/092. Gotham Central v01 - In the Line of Duty.zip	to_parse
1111	DC/01. Crisis to crisis/052. Green Lantern v3 48-55 - Emerald Twilight & New Dawn.zip	to_parse
1112	DC/01. Crisis to crisis/034. Detective Comics - Blind Justice.zip	to_parse
1113	DC/01. Crisis to crisis/069. Batman - No Man's Land v02.zip	to_parse
1114	DC/01. Crisis to crisis/042. Superman - The Return of Superman.zip	to_parse
1115	DC/01. Crisis to crisis/185. Batman R.I.P. - Part II (from issues).zip	to_parse
1116	DC/01. Crisis to crisis/213. Blackest Night Part I (from issues) - Prologue + BN 01-02 + Tie-ins.zip	to_parse
1117	DC/01. Crisis to crisis/227. Knight and Squire.zip	to_parse
1118	DC/01. Crisis to crisis/075. Superman - Red Son.zip	to_parse
1119	DC/01. Crisis to crisis/082. Batman - New Gotham v02.zip	to_parse
1120	DC/01. Crisis to crisis/238. The Flash Secret Files and Origins.zip	to_parse
1121	DC/01. Crisis to crisis/050. Batman - Prodigal.zip	to_parse
1122	DC/01. Crisis to crisis/102. Superman & Batman 08-13 + 19 - Supergirl.zip	to_parse
1123	DC/01. Crisis to crisis/088. Batman - Bruce Wayne - Fugitive.zip	to_parse
1124	DC/01. Crisis to crisis/175. Batman 667-669 + 672-675 - The Black Glove.zip	to_parse
1125	DC/01. Crisis to crisis/178. The Flash, The Fastest Man Alive 07-13 - Full Throttle.zip	to_parse
1126	DC/01. Crisis to crisis/047. Batman - Knightquest - The Search.zip	to_parse
1128	DC/01. Crisis to crisis/166. Crisis Aftermath - Ion 01-12.zip	to_parse
1129	DC/01. Crisis to crisis/096. Outsiders v3 01-07 - Looking for Trouble.zip	to_parse
1130	DC/01. Crisis to crisis/240. Flashpoint Part II (from issues) - FP 04-05 + Tie-Ins.zip	to_parse
1131	DC/01. Crisis to crisis/121. Superman - Sacrifice.zip	to_parse
1132	DC/01. Crisis to crisis/142. JLA Classified 01-03 - Ultramarine Corps.zip	to_parse
1133	DC/01. Crisis to crisis/021. Robin Year One.zip	to_parse
1134	DC/01. Crisis to crisis/024. Legends 01-06.zip	to_parse
1135	DC/01. Crisis to crisis/164. Fifty Two v03.zip	to_parse
1136	DC/01. Crisis to crisis/106. Superman & Batman 14-18 - Absolute Power.zip	to_parse
1137	DC/01. Crisis to crisis/056. Starman v02 - Night and Day.zip	to_parse
1138	DC/01. Crisis to crisis/139. Superman v2 217 + 221-225 -  The Journey.zip	to_parse
1139	DC/01. Crisis to crisis/036. Batman - Son of the demon.zip	to_parse
1140	DC/01. Crisis to crisis/133.b Superman - For Tomorrow.zip	to_parse
1141	DC/01. Crisis to crisis/038. Batman - Birth of the Demon.zip	to_parse
1142	DC/01. Crisis to crisis/173. Batman 655-658 + 663-666 - Batman & Son.zip	to_parse
1143	DC/01. Crisis to crisis/064. DC One Million Part III (from issues).zip	to_parse
1144	DC/01. Crisis to crisis/232. Batman Incorporated v2 v02 - Gotham's Most Wanted.zip	to_parse
1145	DC/01. Crisis to crisis/140. Action Comics 827-828 + 830-835 - Strange Attractors.zip	to_parse
1146	DC/01. Crisis to crisis/144. JLA 115-119 - Crisis of Conscience.zip	to_parse
1147	DC/01. Crisis to crisis/005. Crisis on Multiple Earths v03.zip	to_parse
1148	DC/01. Crisis to crisis/192. Batman - Battle for the Cowl (from issues).zip	to_parse
1149	DC/01. Crisis to crisis/152. Birds of Prey 92-95 - Progeny (One Year Later).zip	to_parse
1150	DC/01. Crisis to crisis/083. Joker Last Laugh 01-06.zip	to_parse
1151	DC/01. Crisis to crisis/017. Legends of the Dark Knight - Gothic.zip	to_parse
1152	DC/01. Crisis to crisis/132. Outsiders v3 16-23 - Wanted.zip	to_parse
1153	DC/01. Crisis to crisis/045. Batman - The Crusade v01.zip	to_parse
1154	DC/01. Crisis to crisis/212. Green Lantern Corps v2 33-38 - Emerald Eclipse.zip	to_parse
1155	DC/01. Crisis to crisis/217. Secret Six v03 - Cat's Cradle.zip	to_parse
1156	DC/01. Crisis to crisis/076. JLA - Earth 2.cbz	to_parse
1157	DC/01. Crisis to crisis/156. Justice League of America v2 01-07 - The Tornado's Path (One Year Later).zip	to_parse
1158	DC/01. Crisis to crisis/172. The Black Case Book.zip	to_parse
1159	DC/01. Crisis to crisis/065. DC One Million Part IV (from issues).zip	to_parse
1160	DC/01. Crisis to crisis/031. Green Arrow - The Longbow Hunters.zip	to_parse
1162	DC/01. Crisis to crisis/026. Justice League - A New Beginning.zip	to_parse
1163	DC/01. Crisis to crisis/033. Batman - A Death in the Family.zip	to_parse
1164	DC/01. Crisis to crisis/225. Brightest Day Part III (from issues) - BD 13-14 + Tie-ins.zip	to_parse
1165	DC/01. Crisis to crisis/183. Heart of Hush.zip	to_parse
1166	DC/01. Crisis to crisis/058. The Kingdom (from issues).zip	to_parse
1167	DC/01. Crisis to crisis/035. Batman - Dark Knight, Dark City.zip	to_parse
1168	DC/01. Crisis to crisis/111. Flash v2 207-217 - The secret of Barry Allen.zip	to_parse
1169	DC/01. Crisis to crisis/206. Batgirl - Stephanie Brown v01.zip	to_parse
1170	DC/01. Crisis to crisis/211. Green Lantern v4 39-42 - Agent Orange.zip	to_parse
1171	DC/01. Crisis to crisis/107. Gotham Central v04 - Corrigan.zip	to_parse
1173	DC/01. Crisis to crisis/214. Blackest Night Part II (from issues) - BN 03-04 + Tie-ins.zip	to_parse
1174	DC/01. Crisis to crisis/109. Detective Comics 801-808 + 811-814 - City of Crime.zip	to_parse
1175	DC/01. Crisis to crisis/231. Batman Incorporated v2 v01 - Demon Star.zip	to_parse
1176	DC/01. Crisis to crisis/220. Batman 703.zip	to_parse
1177	DC/01. Crisis to crisis/157. Teen Titans v3 34-41 - Titans around the World (One Year Later).zip	to_parse
1178	DC/01. Crisis to crisis/023. New Titans 50-54 + Bonus - Who is Donna Troy.zip	to_parse
1179	DC/01. Crisis to crisis/053. Zero Hour - Crisis in Time.zip	to_parse
1180	DC/01. Crisis to crisis/074. Day of Judgment 01-05 + Secret Files and Origins.zip	to_parse
1181	DC/01. Crisis to crisis/118. Green Lantern v4 01-06 - No Fear.zip	to_parse
1182	DC/01. Crisis to crisis/190. Whatever happened to the caped crusader.zip	to_parse
1183	DC/01. Crisis to crisis/025. Swamp Thing v05 - Earth to Earth.zip	to_parse
1185	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 26 - Robin 140.zip	to_parse
1186	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 08 - Infinite Crisis 01.zip	to_parse
1187	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 43 - Batman 650.zip	to_parse
1188	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 34 - JLA 122.zip	to_parse
1189	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 65 - Infinite Crisis 06.cbz	to_parse
1190	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 35 - JLA 123.zip	to_parse
1191	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 07 - Teen Titans 31.cbz	to_parse
1192	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 59 - Adventures of Superman 649.cbz	to_parse
1193	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 49 - Green Arrow 55.zip	to_parse
1194	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 87 - Green Lantern 12.zip	to_parse
1195	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 22 - Outsiders 30.zip	to_parse
1196	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 15 - Infinite Crisis 03 pages 08-22.zip	to_parse
1197	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 01 - Wonder Woman 218.cbz	to_parse
1198	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 03 - Wonder Woman 220.zip	to_parse
1199	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 52 - Green Arrow 58.zip	to_parse
1200	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 02 - Wonder Woman 219.zip	to_parse
1201	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 83 - Green Lantern 08.zip	to_parse
1202	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 30 - Robin 144.zip	to_parse
1203	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 64 - Teen Titans 33.zip	to_parse
1204	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 71 - JSA 85.zip	to_parse
1205	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 11 - Wonder Woman 223.zip	to_parse
1206	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 84 - Green Lantern 09.zip	to_parse
1207	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 50 - Green Arrow 56.zip	to_parse
1208	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 23 - Outsiders 31.zip	to_parse
1209	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 74 - JLA 122.zip	to_parse
1210	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 31 - Robin 145.zip	to_parse
1211	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 75 - JLA 123.zip	to_parse
1212	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 10 - Wonder Woman 222.zip	to_parse
1343	Marvel/Lu/Runaways/Runaways v01 09.zip	to_parse
1344	Marvel/Lu/Runaways/Runaways v01 05.zip	to_parse
1213	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 46 - Rann-Thanagar War - Infinite Crisis Special.cbz	to_parse
1214	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 85 - Green Lantern 10.zip	to_parse
1215	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 19 - Infinite Crisis 03 pages 23-32.zip	to_parse
1216	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 80 - Supergirl 08.zip	to_parse
1217	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 33 - JLA 121.zip	to_parse
1218	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 88 - Green Lantern 13.zip	to_parse
1271	DC/01. Crisis to crisis/127. Adventures of Superman 640-641 + 644-647 - Ruin Revealed.zip	to_parse
1220	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 37 - JLA 125.zip	to_parse
1221	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 40 - Batman 647.zip	to_parse
1222	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 72 - JSA 86.zip	to_parse
1224	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 81 - Supergirl 09.zip	to_parse
1225	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 62 - Infinite Crisis 05 pages 13-34.zip	to_parse
1226	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 29 - Robin 143.zip	to_parse
1227	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 68 - Infinite Crisis 07.cbz	to_parse
1228	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 05 - Teen Titans 29.zip	to_parse
1229	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 28 - Robin 142.zip	to_parse
1230	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 57 - Superman 226.zip	to_parse
1231	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 69 - JSA 83.zip	to_parse
1232	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 44 - Teen Titans 32.cbz	to_parse
1233	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 25 - Outsiders 33.zip	to_parse
1234	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 63 - Teen Titans Annual 01.zip	to_parse
1235	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 79 - Superman & Batman 27.cbz	to_parse
1236	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 32 - JLA 120.zip	to_parse
1237	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 06 - Teen Titans 30.zip	to_parse
1238	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 67 - Villains United - Infinite Crisis Special.cbz	to_parse
1239	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 04 - Wonder Woman 221.zip	to_parse
1240	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 17 - Wonder Woman 226.cbz	to_parse
1241	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 60 - Infinite Crisis Secret Files and Origins.cbz	to_parse
1242	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 18 - JSA 82.zip	to_parse
1243	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 77 - Supergirl 06.zip	to_parse
1244	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 27 - Robin 141.zip	to_parse
1245	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 13 - Infinite Crisis 03 pages 01-07.zip	to_parse
1246	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 24 - Outsiders 32.zip	to_parse
1247	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 70 - JSA 84.zip	to_parse
1248	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 45 - Infinite Crisis 04.cbz	to_parse
1249	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 76 - Superman 223.zip	to_parse
1250	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 39 - Batman 646.zip	to_parse
1251	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 73 - JSA 87.zip	to_parse
1252	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 58 - Action Comics 836.cbz	to_parse
1253	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 51 - Green Arrow 57.zip	to_parse
1254	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 53 - Green Arrow 59.zip	to_parse
1256	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 48 - Green Arrow 54.zip	to_parse
1257	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 21 - Outsiders 29.zip	to_parse
1258	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 42 - Batman 649.zip	to_parse
1259	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 86 - Green Lantern 11.zip	to_parse
1260	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 55 - Robin 147.zip	to_parse
1261	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 36 - JLA 124.zip	to_parse
1262	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 14 - Wonder Woman 224.zip	to_parse
1263	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 54 - Robin 146.zip	to_parse
1264	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 66 - The O.M.A.C. Project - Infinite Crisis Special.zip	to_parse
1265	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 16 - Wonder Woman 225.cbz	to_parse
1266	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 78 - Supergirl 07.zip	to_parse
1345	Marvel/Lu/Runaways/Runaways v03 07.cbz	to_parse
1267	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 61 - Batman Annual 25.zip	to_parse
1268	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 82 - Green Lantern 07.zip	to_parse
1269	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 09 - Infinite Crisis 02 pages 01-29.zip	to_parse
1270	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 12 - Infinite Crisis 02 pages 30-31.zip	to_parse
1272	DC/01. Crisis to crisis/165. Fifty Two v04.zip	to_parse
1274	DC/01. Crisis to crisis/108. Superman & Batman 20-25 - Vengeance.zip	to_parse
1275	DC/01. Crisis to crisis/163. Fifty Two v02.zip	to_parse
1276	DC/01. Crisis to crisis/233. The Black Mirror.zip	to_parse
1277	DC/01. Crisis to crisis/098. Gotham Central v03 - On the Freak Beat.zip	to_parse
1278	DC/01. Crisis to crisis/199. Batman and Robin v01 - Batman Reborn.zip	to_parse
1279	DC/01. Crisis to crisis/116. Green Lantern - Rebirth 01-06.zip	to_parse
1280	DC/01. Crisis to crisis/029. Animal Man v03 - Deus Ex Machina.zip	to_parse
1281	DC/01. Crisis to crisis/071. Batman - No Man's Land v03.zip	to_parse
1283	DC/01. Crisis to crisis/004. Crisis on Multiple Earths v02.zip	to_parse
1284	DC/01. Crisis to crisis/073. Batman - No Man's Land Bonus - Secret Files and Origins + Gallery.zip	to_parse
1285	DC/01. Crisis to crisis/186. Final Crisis - Part I (from issues).zip	to_parse
1286	DC/01. Crisis to crisis/018. Legends of the Dark Knight - Prey.zip	to_parse
1287	DC/01. Crisis to crisis/072. Batman - No Man's Land v04.zip	to_parse
1288	DC/01. Crisis to crisis/105. Batman - War Games v02.zip	to_parse
1289	DC/01. Crisis to crisis/159. Green Lantern v4 14-20 - Wanted (One Year Later).zip	to_parse
1290	DC/01. Crisis to crisis/100. Superman & Batman 01-07 - Public Enemies.zip	to_parse
1291	DC/01. Crisis to crisis/174.b Detective Comics 840 - The Resurection of Ra's Al Ghul - Epilogue.zip	to_parse
1292	DC/01. Crisis to crisis/063. DC One Million Part II (from issues).zip	to_parse
1293	DC/01. Crisis to crisis/188. Final Crisis - Part II (from issues).zip	to_parse
1294	DC/01. Crisis to crisis/054. The Final Night.zip	to_parse
1295	DC/01. Crisis to crisis/125. Manhunter v3 06-14 - Trial by fire.zip	to_parse
1296	DC/01. Crisis to crisis/180. Justice League of America v2 17-21 - Sanctuary.zip	to_parse
1297	DC/01. Crisis to crisis/234. Secret Six v04 - Caution to the Wind.zip	to_parse
1298	DC/01. Crisis to crisis/158. Superman & Action Comics - Up, Up and Away (One Year Later - from issues).zip	to_parse
1299	Marvel/Lu/Moon Knight/Moon Knight 02.zip	to_parse
1300	Marvel/Lu/Moon Knight/Moon Knight 01.zip	to_parse
1301	Marvel/Lu/Magneto Testament/X-Men - Magneto Testament 02.zip	to_parse
1302	Marvel/Lu/Magneto Testament/X-Men - Magneto Testament 04.zip	to_parse
1303	Marvel/Lu/Magneto Testament/X-Men - Magneto Testament 05.zip	to_parse
1304	Marvel/Lu/Magneto Testament/X-Men - Magneto Testament 03.zip	to_parse
1305	Marvel/Lu/Magneto Testament/X-Men - Magneto Testament 01.zip	to_parse
1306	Marvel/Lu/Wolverine Origin/Wolverine Origin 03.zip	to_parse
1307	Marvel/Lu/Wolverine Origin/Wolverine Origin 02.zip	to_parse
1308	Marvel/Lu/Wolverine Origin/Wolverine Origin 06.zip	to_parse
1309	Marvel/Lu/Wolverine Origin/Wolverine Origin 05.zip	to_parse
1310	Marvel/Lu/Wolverine Origin/Wolverine Origin 04.zip	to_parse
1311	Marvel/Lu/Wolverine Origin/Wolverine Origin 01.zip	to_parse
1312	Marvel/Lu/Magneto/Magneto 08.zip	to_parse
1313	Marvel/Lu/Magneto/Magneto 06.zip	to_parse
1314	Marvel/Lu/Magneto/Magneto 02.zip	to_parse
1315	Marvel/Lu/Magneto/Magneto 04.zip	to_parse
1316	Marvel/Lu/Magneto/Magneto 05.zip	to_parse
1317	Marvel/Lu/Magneto/Magneto 03.zip	to_parse
1318	Marvel/Lu/Magneto/Magneto 10.zip	to_parse
1319	Marvel/Lu/Magneto/Magneto 01.zip	to_parse
1320	Marvel/Lu/Magneto/Magneto 07.zip	to_parse
1321	Marvel/Lu/Magneto/Magneto 09.zip	to_parse
1322	Marvel/Lu/Magneto/Magneto 11.zip	to_parse
1324	Marvel/Lu/Deadpool/Deadpool Killogy/01. Deadpool Kills the Marvel Universe/Deadpool Kills the Marvel Universe 03.zip	to_parse
1325	Marvel/Lu/Deadpool/Deadpool Killogy/01. Deadpool Kills the Marvel Universe/Deadpool Kills the Marvel Universe 04.zip	to_parse
1326	Marvel/Lu/Deadpool/Deadpool Killogy/01. Deadpool Kills the Marvel Universe/Deadpool Kills the Marvel Universe 01.zip	to_parse
1327	Marvel/Lu/Deadpool/Deadpool Killogy/02. Deadpool Killustrated/Deadpool Killustrated 02.zip	to_parse
1328	Marvel/Lu/Deadpool/Deadpool Killogy/02. Deadpool Killustrated/Deadpool Killustrated 01.zip	to_parse
1329	Marvel/Lu/Deadpool/Deadpool Killogy/02. Deadpool Killustrated/Deadpool Killustrated 04.zip	to_parse
1330	Marvel/Lu/Deadpool/Deadpool Killogy/02. Deadpool Killustrated/Deadpool Killustrated 03.zip	to_parse
1331	Marvel/Lu/Deadpool/Deadpool Killogy/03. Deadpool Kills Deadpool/Deadpool Kills Deadpool 04.zip	to_parse
1332	Marvel/Lu/Deadpool/Deadpool Killogy/03. Deadpool Kills Deadpool/Deadpool Kills Deadpool 03.zip	to_parse
1333	Marvel/Lu/Deadpool/Deadpool Killogy/03. Deadpool Kills Deadpool/Deadpool Kills Deadpool 02.zip	to_parse
1334	Marvel/Lu/Deadpool/Deadpool Killogy/03. Deadpool Kills Deadpool/Deadpool Kills Deadpool 01.zip	to_parse
1335	Marvel/Lu/Deadpool/Living Deadpool/02. Return of the Living Deadpool/Return of the Living Deadpool 03.zip	to_parse
1336	Marvel/Lu/Deadpool/Living Deadpool/02. Return of the Living Deadpool/Return of the Living Deadpool 02.zip	to_parse
1337	Marvel/Lu/Deadpool/Living Deadpool/02. Return of the Living Deadpool/Return of the Living Deadpool 04.zip	to_parse
1338	Marvel/Lu/Deadpool/Living Deadpool/02. Return of the Living Deadpool/Return of the Living Deadpool 01.zip	to_parse
1339	Marvel/Lu/Deadpool/Living Deadpool/01. Night of the Living Deadpool/Night of the Living Deadpool 04.zip	to_parse
1340	Marvel/Lu/Deadpool/Living Deadpool/01. Night of the Living Deadpool/Night of the Living Deadpool 01.zip	to_parse
1341	Marvel/Lu/Deadpool/Living Deadpool/01. Night of the Living Deadpool/Night of the Living Deadpool 03.zip	to_parse
1342	Marvel/Lu/Deadpool/Living Deadpool/01. Night of the Living Deadpool/Night of the Living Deadpool 02.zip	to_parse
1346	Marvel/Lu/Runaways/Runaways v02 10.zip	to_parse
1347	Marvel/Lu/Runaways/Runaways v02 07.zip	to_parse
1349	Marvel/Lu/Runaways/Runaways v02 22.zip	to_parse
1350	Marvel/Lu/Runaways/Runaways v02 15.zip	to_parse
1351	Marvel/Lu/Runaways/Runaways v02 25.zip	to_parse
1352	Marvel/Lu/Runaways/Runaways v03 12.cbz	to_parse
1353	Marvel/Lu/Runaways/Runaways v01 15.zip	to_parse
1354	Marvel/Lu/Runaways/Runaways v01 07.zip	to_parse
1355	Marvel/Lu/Runaways/Runaways v03 13.cbz	to_parse
1356	Marvel/Lu/Runaways/Runaways v01 10.zip	to_parse
1357	Marvel/Lu/Runaways/Runaways v01 14.zip	to_parse
1358	Marvel/Lu/Runaways/Runaways v02 17.zip	to_parse
1359	Marvel/Lu/Runaways/Runaways v02 26.zip	to_parse
1360	Marvel/Lu/Runaways/Runaways v02 08.zip	to_parse
1362	Marvel/Lu/Runaways/Extras/Marvel - X-Men  Runaways.zip	to_parse
1363	Marvel/Lu/Runaways/Extras/Secret Invasion - Young Avengers & Runaways 01.zip	to_parse
1364	Marvel/Lu/Runaways/Extras/Civil War - Young Avengers & Runaways 01.zip	to_parse
1365	Marvel/Lu/Runaways/Extras/Civil War - Young Avengers & Runaways 03.zip	to_parse
1366	Marvel/Lu/Runaways/Extras/Civil War - Young Avengers & Runaways 04.zip	to_parse
1367	Marvel/Lu/Runaways/Extras/Secret Invasion - Young Avengers & Runaways 02.zip	to_parse
1368	Marvel/Lu/Runaways/Extras/Runaways Saga.zip	to_parse
1369	Marvel/Lu/Runaways/Extras/Civil War - Young Avengers & Runaways 02.zip	to_parse
1370	Marvel/Lu/Runaways/Extras/Secret Invasion - Young Avengers & Runaways 03.zip	to_parse
1371	Marvel/Lu/Runaways/Runaways v01 11.zip	to_parse
1372	Marvel/Lu/Runaways/Runaways v01 12.zip	to_parse
1373	Marvel/Lu/Runaways/Runaways v03 10.cbz	to_parse
1374	Marvel/Lu/Runaways/Runaways v03 03.cbz	to_parse
1375	Marvel/Lu/Runaways/Runaways v03 14.cbz	to_parse
1376	Marvel/Lu/Runaways/Runaways v01 17.zip	to_parse
1377	Marvel/Lu/Runaways/Runaways v02 12.zip	to_parse
1378	Marvel/Lu/Runaways/Runaways v02 21.zip	to_parse
1379	Marvel/Lu/Runaways/Runaways v02 24.zip	to_parse
1380	Marvel/Lu/Runaways/Runaways v02 05.zip	to_parse
1381	Marvel/Lu/Runaways/Runaways v03 06.cbz	to_parse
1382	Marvel/Lu/Runaways/Runaways v03 05.cbz	to_parse
1383	Marvel/Lu/Runaways/Runaways v02 30.zip	to_parse
1384	Marvel/Lu/Runaways/Runaways v03 09.cbz	to_parse
1385	Marvel/Lu/Runaways/Runaways v03 08.cbz	to_parse
1387	Marvel/Lu/Runaways/Runaways v02 01.zip	to_parse
1388	Marvel/Lu/Runaways/Runaways v01 16.zip	to_parse
1389	Marvel/Lu/Runaways/Runaways v02 03.zip	to_parse
1390	Marvel/Lu/Runaways/Runaways v02 20.zip	to_parse
1391	Marvel/Lu/Runaways/Runaways v03 04.cbz	to_parse
1392	Marvel/Lu/Runaways/Runaways v02 23.zip	to_parse
1393	Marvel/Lu/Runaways/Runaways v01 13.zip	to_parse
1394	Marvel/Lu/Runaways/Runaways v01 18.zip	to_parse
1395	Marvel/Lu/Runaways/Runaways v02 16.zip	to_parse
1396	Marvel/Lu/Runaways/Runaways v03 02.cbz	to_parse
1397	Marvel/Lu/Runaways/Runaways v01 01.zip	to_parse
1398	Marvel/Lu/Runaways/Runaways v01 06.zip	to_parse
1399	Marvel/Lu/Runaways/Runaways v02 29.zip	to_parse
1400	Marvel/Lu/Runaways/Runaways v01 08.zip	to_parse
1401	Marvel/Lu/Runaways/Runaways v02 27.zip	to_parse
1402	Marvel/Lu/Runaways/Runaways v01 04.zip	to_parse
1403	Marvel/Lu/Runaways/Runaways v02 04.zip	to_parse
1404	Marvel/Lu/Runaways/Runaways v02 28.zip	to_parse
1406	Marvel/Lu/Runaways/Runaways v03 11.cbz	to_parse
1407	Marvel/Lu/Runaways/Runaways v03 01.cbz	to_parse
1408	Marvel/Lu/Runaways/Runaways v02 19.zip	to_parse
1409	Marvel/Lu/Runaways/Runaways v02 11.zip	to_parse
1410	Marvel/Lu/Runaways/Runaways v02 14.zip	to_parse
1411	Marvel/Lu/Runaways/Runaways v02 02.zip	to_parse
1412	Marvel/Lu/Runaways/Runaways v01 02.zip	to_parse
1413	Marvel/Lu/Runaways/Runaways v01 03.zip	to_parse
1414	Marvel/Lu/Runaways/Runaways v02 13.zip	to_parse
1416	Marvel/Ultimate Universe/050. Ultimate Fantastic Four Annual 02.zip	to_parse
1417	Marvel/Ultimate Universe/154. All-New Ultimates 01-03.zip	to_parse
1418	Marvel/Ultimate Universe/031. Ultimate Spider-Man 47-53 - Cats and Kings.zip	to_parse
1419	Marvel/Ultimate Universe/096. Ultimate Spider-Man 121 - Omega Red.zip	to_parse
1420	Marvel/Ultimate Universe/138. United, We Stand - Part 2.zip	to_parse
1421	Marvel/Ultimate Universe/132. Ultimate Comics Ultimates 07-12 - Two Cities, Two Worlds.zip	to_parse
1422	Marvel/Ultimate Universe/060. The Ultimates Annual 01.zip	to_parse
1423	Marvel/Ultimate Universe/148. Age of Ultron 10 + Hunger 01-04.zip	to_parse
1424	Marvel/Ultimate Universe/111. Ultimate Avengers 01-06 - The Next Generation.zip	to_parse
1425	Marvel/Ultimate Universe/039. Ultimate Spider-Man 60-65 - Carnage.zip	to_parse
1426	Marvel/Ultimate Universe/119. Ultimate New Ultimates 01-05.zip	to_parse
1427	Marvel/Ultimate Universe/051. Ultimate Spider-Man 79-85 - Warriors.zip	to_parse
1428	Marvel/Ultimate Universe/032. Ultimate Adventures 01-06.zip	to_parse
1429	Marvel/Ultimate Universe/086. Ultimate Fantastic Four 50-53 - Four Cubed.zip	to_parse
1430	Marvel/Ultimate Universe/082. Ultimate Fantastic Four 39-41 - Devils.zip	to_parse
1431	Marvel/Ultimate Universe/001. Ultimate Spider-Man 01-07 - Power & Responsibility.zip	to_parse
1432	Marvel/Ultimate Universe/019. Ultimate Spider-Man v01 28-32 - Public Scrutiny.zip	to_parse
1433	Marvel/Ultimate Universe/099. Ultimates Saga.zip	to_parse
1434	Marvel/Ultimate Universe/123. Ultimate Spider-man 156-160 - Death of Spider-Man.zip	to_parse
1435	Marvel/Ultimate Universe/004. Ultimate Marvel Team-Up 04-05.zip	to_parse
1436	Marvel/Ultimate Universe/095. Ultimate Spider-Man Annual 03.zip	to_parse
1437	Marvel/Ultimate Universe/045. Ultimate Spider-Man 72-77 - Hobgoblin.zip	to_parse
1438	Marvel/Ultimate Universe/105. Ultimatum Part 1 - Ultimatum01-02 + Tie-Ins.zip	to_parse
1439	Marvel/Ultimate Universe/115. Ultimate Enemy 01-04.zip	to_parse
1441	Marvel/Ultimate Universe/085. Ultimate Fantastic Four 47-49 - Ghosts.zip	to_parse
1442	Marvel/Ultimate Universe/079. Ultimate X-Men 81 - Cliffhanger.zip	to_parse
1443	Marvel/Ultimate Universe/029. Ultimate Spider-Man 0.5.zip	to_parse
1444	Marvel/Ultimate Universe/129. Ultimate Comics X-Men 01-06.zip	to_parse
1446	Marvel/Ultimate Universe/092. Ultimate Captain America Annual.zip	to_parse
1447	Marvel/Ultimate Universe/113. Ultimate Avengers v2 01-06 - Crime & Punishment.zip	to_parse
1448	Marvel/Ultimate Universe/013. Ultimate X-Men 15 - A Different World Is Possible.zip	to_parse
1449	Marvel/Ultimate Universe/150. Cataclysm - Part 2.zip	to_parse
1450	Marvel/Ultimate Universe/140. Ultimate Comics Ultimates 19-24 - Reconstruction.zip	to_parse
1451	Marvel/Ultimate Universe/007. Ultimate Marvel Team-Up 06-08.zip	to_parse
1452	Marvel/Ultimate Universe/012. Ultimate X-Men 13-14 - You Always Remember Your First Love.zip	to_parse
1453	Marvel/Ultimate Universe/055. Ultimate Secret 01-04.zip	to_parse
1454	Marvel/Ultimate Universe/067. Ultimate X-Men 66-68 - Date Night.zip	to_parse
1455	Marvel/Ultimate Universe/108. Ultimate Armor Wars 01-04.zip	to_parse
1456	Marvel/Ultimate Universe/121. Ultimate Spider-Man v2 15 + 150-155 - Death of Spier-Man Prelude.zip	to_parse
1457	Marvel/Ultimate Universe/087. Ultimate Human 01-04.zip	to_parse
1458	Marvel/Ultimate Universe/006. Ultimate Elektra 01-05 - Devil's Due.zip	to_parse
1459	Marvel/Ultimate Universe/024. Ultimate X-Men 21-25 - Hellfire and Brimstone.zip	to_parse
1460	Marvel/Ultimate Universe/074. Ultimate Spider-Man 95-96 - Morbius.zip	to_parse
1461	Marvel/Ultimate Universe/102. Ultimate X-Men 94-97 - Absolute Power.zip	to_parse
1462	Marvel/Ultimate Universe/151. Survive.zip	to_parse
1463	Marvel/Ultimate Universe/069. Ultimate Wolverine Vs. Hulk 01-06.zip	to_parse
1464	Marvel/Ultimate Universe/063. Ultimate X4 01-02.zip	to_parse
1465	Marvel/Ultimate Universe/122. Ultimate Avengers v3 01-06 - Blade vs. the Avengers.zip	to_parse
1466	Marvel/Ultimate Universe/046. Ultimate Spider-Man 78 - Dumped.zip	to_parse
1467	Marvel/Ultimate Universe/136. Divided, We Fall.zip	to_parse
1468	Marvel/Ultimate Universe/104. Ultimate Origins 01-05.zip	to_parse
1469	Marvel/Ultimate Universe/126. Ultimate Comics Spider-Man 01-06 - Who is Miles Morales.zip	to_parse
1470	Marvel/Ultimate Universe/157. All-New Ultimates 04-12.zip	to_parse
1471	Marvel/Ultimate Universe/158. Ultimate FF 06.zip	to_parse
1472	Marvel/Ultimate Universe/152. Ultimate Comics Spider-Man 200.zip	to_parse
1473	Marvel/Ultimate Universe/107. Ultimatum Requiem - Fantastic Four, X-Men, Spider-Man.zip	to_parse
1474	Marvel/Ultimate Universe/124. Ultimate Avengers vs New Ultimates 01-06.zip	to_parse
1475	Marvel/Ultimate Universe/125. Ultimate Fallout 01-06.zip	to_parse
1476	Marvel/Ultimate Universe/047. Ultimate Fantastic Four Annual 01.zip	to_parse
1477	Marvel/Ultimate Universe/065. Ultimate Spider-Man 86-90 - Silver Sable.zip	to_parse
1478	Marvel/Ultimate Universe/058. Ultimate Vision 01-05.zip	to_parse
1479	Marvel/Ultimate Universe/005. Ultimate Daredevil and Elektra 01-04.zip	to_parse
1480	Marvel/Ultimate Universe/009. Ultimate Spider-Man 14-21 - Double Trouble.zip	to_parse
1481	Marvel/Ultimate Universe/053. Ultimate X-Men 59-60 - Shock and Awe.zip	to_parse
1482	Marvel/Ultimate Universe/144. Ultimate Comics Iron Man 01-04.zip	to_parse
1484	Marvel/Ultimate Universe/127. Ultimate Comics Ultimates 01-04 - The Republic is Burning.zip	to_parse
1485	Marvel/Ultimate Universe/098. Ultimate Spider-Man 123-128 - War of the Symbiotes.zip	to_parse
1486	Marvel/Ultimate Universe/112. Ultimate Spider-Man v2 07-08 - Crossroad.zip	to_parse
1487	Marvel/Ultimate Universe/094. Ultimate Spider-Man 118-120 - And His Amazing Friends.zip	to_parse
1488	Marvel/Ultimate Universe/106. Ultimatum Part 2 - Ultimatum 03-05 + Tie-Ins.zip	to_parse
1489	Marvel/Ultimate Universe/149. Cataclysm - Part 1.zip	to_parse
1490	Marvel/Ultimate Universe/034. Ultimate Fantastic Four 01-06 - The Fantastic.zip	to_parse
1491	Marvel/Ultimate Universe/042. Ultimate Fantastic Four 19-20 - Think Tank.zip	to_parse
1492	Marvel/Ultimate Universe/072. Ultimate X-Men 72-74 - Magical.zip	to_parse
1493	Marvel/Ultimate Universe/030. Ultimate X-Men 34-39 - Blockbuster.zip	to_parse
1494	Marvel/Ultimate Universe/041. Ultimate Fantastic Four 13-18 - N-Zone.zip	to_parse
1495	Marvel/Ultimate Universe/117. Ultimate Doom 01-04.zip	to_parse
1496	Marvel/Ultimate Universe/080. Ultimate X-Men 82-83 - The Underneath.zip	to_parse
1497	Marvel/Ultimate Universe/035. Ultimate Spider-Man 54-59 - Hollywood.zip	to_parse
1498	Marvel/Ultimate Universe/142. Ultimate Comics Wolverine 01-04 - Legacies.zip	to_parse
1499	Marvel/Ultimate Universe/052. Ultimate X-Men 54-58 - The Most Dangerous Game.zip	to_parse
1500	Marvel/Ultimate Universe/159. Miles Morales - Ultimate Spider-Man 10-12.zip	to_parse
1501	Marvel/Ultimate Universe/061. Ultimate X-Men Annual 01.zip	to_parse
1502	Marvel/Ultimate Universe/139. Ultimate Comics Spider-Man 16.1 + 19-22 - Venom War.zip	to_parse
1503	Marvel/Ultimate Universe/147. Ultimate Comics Spider-Man 23-28 - Spider-Man No More.zip	to_parse
1504	Marvel/Ultimate Universe/070. The Ultimates v2 07-13 - Grand Theft America.zip	to_parse
1505	Marvel/Ultimate Universe/097. Ultimate Spider-Man 122 - The Worst Day in Peter Parker's Life.zip	to_parse
1506	Marvel/Ultimate Universe/114. Ultimate Spider-Man v2 09-14 - Chameleons.zip	to_parse
1507	Marvel/Ultimate Universe/056. Ultimate Vision 00.zip	to_parse
1508	Marvel/Ultimate Universe/155. Miles Morales - Ultimate Spider-Man 01-09.zip	to_parse
1509	Marvel/Ultimate Universe/017. Ultimate Spider-Man 22-27 - Legacy.zip	to_parse
1510	Marvel/Ultimate Universe/002. Ultimate Marvel Team-Up 01-03.zip	to_parse
1511	Marvel/Ultimate Universe/100. The Ultimates v3 01-05 - Who Killed the Scarlet Witch.zip	to_parse
1512	Marvel/Ultimate Universe/130. Ultimate Comics Ultimates 05-06 - The World.zip	to_parse
1514	Marvel/Ultimate Universe/128. Ultimate Hawkeye 01-04.zip	to_parse
1515	Marvel/Ultimate Universe/054. Ultimate Nightmare 01-05.zip	to_parse
1516	Marvel/Ultimate Universe/073. Ultimate X-Men Annual 02.zip	to_parse
1517	Marvel/Ultimate Universe/015. Ultimate X-Men 20 - Resignation.zip	to_parse
1518	Marvel/Ultimate Universe/090. Ultimate X-Men 89 - Shadow King.zip	to_parse
1519	Marvel/Ultimate Universe/038. Ultimate X-Men 46-49 - The Tempest.zip	to_parse
1520	Marvel/Ultimate Universe/021. Ultimate Spider-Man 33-39 - Venom.zip	to_parse
1521	Marvel/Ultimate Universe/077. Ultimate Spider-Man 97-105 - Clone Saga.zip	to_parse
1522	Marvel/Ultimate Universe/049. Ultimate Fantastic Four 30-32 - Frightful.zip	to_parse
1523	Marvel/Ultimate Universe/062. Ultimate X-Men 61-65 - Magnetic North.zip	to_parse
1524	Marvel/Ultimate Universe/093. Ultimate Hulk Annual.zip	to_parse
1525	Marvel/Ultimate Universe/101. Ultimate Fantastic Four 54-57 - Salem's Seven.zip	to_parse
1526	Marvel/Ultimate Universe/083. Ultimate Fantastic Four 42-46 - Silver Surfer.zip	to_parse
1527	Marvel/Ultimate Universe/014. Ultimate X-Men 16-19 - World Tour.zip	to_parse
1528	Marvel/Ultimate Universe/023. Ultimate Iron Man v2 01-05.zip	to_parse
1529	Marvel/Ultimate Universe/137. United, We Stand - Part 1.zip	to_parse
1530	Marvel/Ultimate Universe/037. Ultimate Fantastic Four 07-12 - Doom.zip	to_parse
1531	Marvel/Ultimate Universe/081. Ultimate X-Men 84-88 - Sentinels.zip	to_parse
1532	Marvel/Ultimate Universe/010. Ultimate Marvel Team-Up 09-16.zip	to_parse
1533	Marvel/Ultimate Universe/153. Ultimate FF 01-03.zip	to_parse
1535	Marvel/Ultimate Universe/036. Ultimate X-Men 40-45 - New Mutants.zip	to_parse
1536	Marvel/Ultimate Universe/120. Ultimate Thor 01-04.zip	to_parse
1537	Marvel/Ultimate Universe/089. Ultimate Spider-Man 112-117 - Death of a Goblin.zip	to_parse
1538	Marvel/Ultimate Universe/076. Ultimate Fantastic Four 33-38 - God War.zip	to_parse
1539	Marvel/Ultimate Universe/020. The Ultimates 07-13 - Homeland Security.zip	to_parse
1540	Marvel/Ultimate Universe/064. Ultimate Spider-Man Annual 01.zip	to_parse
1541	Marvel/Ultimate Universe/043. Ultimate X-Men 50-53 - Superstars.zip	to_parse
1542	Marvel/Ultimate Universe/116. Ultimate Mystery 01-04.zip	to_parse
1543	Marvel/Ultimate Universe/033. Ultimate Spider-Man 46 + Six 01-07.zip	to_parse
1544	Marvel/Ultimate Universe/059. The Ultimates v2 01-06 - Gods and Monsters.zip	to_parse
1545	Marvel/Ultimate Universe/133. Ultimate Comics X-Men 07-12.zip	to_parse
1546	Marvel/Ultimate Universe/075. Ultimate Spider-Man Annual 02.zip	to_parse
1547	Marvel/Ultimate Universe/109. Ultimate X 01-05.zip	to_parse
1548	Marvel/Ultimate Universe/091. Ultimate X-Men 90-93 - Apocalypse.zip	to_parse
1549	Marvel/Ultimate Universe/025. Ultimate X-Men 26-27 - Return of the King Prelude.zip	to_parse
1550	Marvel/Ultimate Universe/026. Ultimate War 01-04.zip	to_parse
1551	Marvel/Ultimate Universe/040. Ultimate Spider-Man 66-71 - Superstars.zip	to_parse
1552	Marvel/Ultimate Universe/016. The Ultimates 01-06 - Super Human.zip	to_parse
1553	Marvel/Ultimate Universe/057. Ultimate Extinction 01-05.zip	to_parse
1554	Marvel/Ultimate Universe/071. The Ultimates Annual 02.zip	to_parse
1555	Marvel/Ultimate Universe/027. Ultimate X-Men 28-33 - Return of the King.zip	to_parse
1556	Marvel/Ultimate Universe/003. Ultimate Spider-Man 08-13 - Learning Curve.zip	to_parse
1557	Marvel/Ultimate Universe/145. Ultimate Comics X-Men 29-33 - World War X.zip	to_parse
1558	Marvel/Ultimate Universe/135. Ultimate Comics X-Men 13.zip	to_parse
1559	Marvel/Ultimate Universe/088. Ultimate Spider-Man 106-111 - Ultimate Knights.zip	to_parse
1560	Marvel/Ultimate Universe/134. Spider-Men 01-05.zip	to_parse
1561	Marvel/Ultimate Universe/066. Ultimate Spider-Man 91-94 - Deadpool.zip	to_parse
1562	Marvel/Ultimate Universe/156. Ultimate FF 04-05.zip	to_parse
1563	Marvel/Ultimate Universe/078. Ultimate X-Men 75-80 - Cable.zip	to_parse
1564	Marvel/Ultimate Universe/131. Ultimate Comics Spider-Man 07-12.zip	to_parse
1565	Marvel/Ultimate Universe/018. Ultimate Spider-Man Super Special.zip	to_parse
1567	Marvel/Ultimate Universe/084. Ultimate Power 01-09.zip	to_parse
1568	Marvel/Ultimate Universe/028. Ultimate Spider-Man 40-45 - Irresponsible.zip	to_parse
1569	Marvel/Ultimate Universe/118. Ultimate Captain America 01-04.zip	to_parse
1570	Marvel/Ultimate Universe/146. Ultimate Comics Ultimates 25-30 - Ultimates Disassembled.zip	to_parse
1571	Marvel/Ultimate Universe/008. Ultimate X-Men 01-06 + 0.5 - The Tomorrow People.zip	to_parse
1572	Marvel/Ultimate Universe/022. Ultimate Iron Man 01-05.zip	to_parse
1573	Marvel/Ultimate Universe/068. Ultimate X-Men 69-71 - Phoenix.zip	to_parse
1574	Marvel/Death of Wolverine.zip	to_parse
1575	Marvel/Wolverine - Old Man Logan.zip	to_parse
1576	Fini/The Boys v02 - Get Some.zip	to_parse
1577	Fini/Revival - Deluxe Collection v02.zip	to_parse
1578	Fini/Klaus v01.zip	to_parse
1579	Fini/We Stand On Guard.zip	to_parse
1580	Fini/Pride of Baghdad - The Deluxe Edition.zip	to_parse
1581	Fini/Nailbiter/Nailbiter v01-02 - The Murder Edition.zip	to_parse
1582	Fini/Nailbiter/Extras/Nailbiter - Hack-Slash OS.zip	to_parse
1583	Fini/Nailbiter/Nailbiter v04 - Blood Lust.zip	to_parse
1584	Fini/Nailbiter/Nailbiter v05 - Bound by Blood.zip	to_parse
1585	Fini/Nailbiter/Nailbiter v03 - Blood in the Water.zip	to_parse
1586	Fini/Nailbiter/Nailbiter v06 - The Bloody Truth.zip	to_parse
1587	Fini/Coffin Hill v01 - Forest of the Night.zip	to_parse
1588	Fini/Polarity.zip	to_parse
1589	Fini/Ghosted v03 - Death Wish.zip	to_parse
1590	Fini/Peter Panzerfaust v04 - The Hunt.zip	to_parse
1591	Fini/Scalped - The Deluxe Edition Book 01.zip	to_parse
1592	Fini/Ghosted v04 - Ghost Town.zip	to_parse
1593	Fini/The Boys v03 - Good for the Soul.zip	to_parse
1594	Fini/Sunstone v05.zip	to_parse
1595	Fini/Switch 01-04.zip	to_parse
1596	Fini/Casanova v02 - Gula.zip	to_parse
1597	Fini/Starve v01.zip	to_parse
1598	Fini/The Twilight Children.zip	to_parse
1600	Fini/Preacher - Book 04.zip	to_parse
1601	Fini/Sunstone v01.zip	to_parse
1602	Fini/Sunstone v02.zip	to_parse
1603	Fini/The Bunker/02. The Bunker v02.zip	to_parse
1604	Fini/The Bunker/03. The Bunker 10-14.zip	to_parse
1605	Fini/The Bunker/04. The Bunker 15-19.zip	to_parse
1606	Fini/The Bunker/01. The Bunker v01.zip	to_parse
1607	Fini/God Hates Astronauts v01 - The Head That Wouldn't Die.zip	to_parse
1608	Fini/Mage v01 - Book 01 - The Hero Discovered.zip	to_parse
1609	Fini/Preacher - Book 02.zip	to_parse
1610	Fini/Mage v03 - Book 02 - The Hero Defined.zip	to_parse
1611	Fini/The Umbrella Academy v06 - Dallas.zip	to_parse
1612	Fini/Shaolin Cowboy v02 - Shemp Buffet.zip	to_parse
1613	Fini/MPH.zip	to_parse
1614	Fini/The Sandman v10 - The Wake.zip	to_parse
1615	Fini/Letter 44 v04 - Saviors.zip	to_parse
1617	Fini/Rasputin/02. Rasputin 06-10.zip	to_parse
1618	Fini/Kill or Be Killed v03.zip	to_parse
1619	Fini/Bone/Bone v07 - Ghost Circles.zip	to_parse
1620	Fini/Bone/Bone v06 - Old Man's Cave.zip	to_parse
1621	Fini/Bone/Bone v01 - Out From Boneville (Scholastic 2004) (evensteven).zip	to_parse
1622	Fini/Bone/Extras/Bone - Holiday Special.zip	to_parse
1623	Fini/Bone/Extras/Bone - Stupid Stupid Rat-tails 02.zip	to_parse
1624	Fini/Bone/Extras/Bone - Tall Tales.zip	to_parse
1625	Fini/Bone/Extras/Bone - Rose.zip	to_parse
1626	Fini/Bone/Extras/Bone - Trilogy Tour '97.zip	to_parse
1627	Fini/Bone/Extras/Bone - Stupid Stupid Rat-tails 03.zip	to_parse
1628	Fini/Bone/Extras/Bone - Stupid Stupid Rat-tails 01.zip	to_parse
1629	Fini/Bone/Bone v08 - Treasure Hunters.zip	to_parse
1630	Fini/Bone/Bone v04 - The Dragonslayer (Scholastic 2006) (even steven).zip	to_parse
1631	Fini/Bone/Bone v02 - The Great Cow Race (Scholastic 2005) (even steven).zip	to_parse
1632	Fini/Bone/Bone v09 - Crown Of Horns.zip	to_parse
1633	Fini/Bone/Bone v03 - Eyes Of The Storm (Scholastic 2006) (even steven).zip	to_parse
1634	Fini/Bone/Bone v05 - Rock Jaw - Master Of The Eastern Border.zip	to_parse
1635	Fini/FBP - Federal Bureau of Physics v01 - The Paradigm Shift.cbz	to_parse
1636	Fini/Morning Glories v03 - P.E.zip	to_parse
1637	Fini/The Manhattan Projects v05 - The Cold War.zip	to_parse
1638	Fini/Empire v01.zip	to_parse
1639	Fini/Garfield 1978-1989.zip	to_parse
1640	Fini/Annihilator 01-06.zip	to_parse
1641	Fini/Anya's Ghost.zip	to_parse
1642	Fini/Zero v01 - An Emergency.zip	to_parse
1643	Fini/Plutona 01-05.zip	to_parse
1645	Fini/The Invisibles - The Deluxe Edition Book 01.zip	to_parse
1646	Fini/The Boys v06 - The Self-Preservation Society.zip	to_parse
1647	Fini/Evil Empire v03.zip	to_parse
1648	Fini/Morning Glories v05 - Tests.zip	to_parse
1649	Fini/The Manhattan Projects v06 - Sun Beyond the Stars.zip	to_parse
1650	Fini/Velvet v03 - The Man Who Stole the World.zip	to_parse
1651	Fini/Transmetropolitan v08 - Dirge.zip	to_parse
1652	Fini/Preacher - Book 06.zip	to_parse
1653	Fini/March - Book 3.zip	to_parse
1654	Fini/The Fade Out v01 - Act One.zip	to_parse
1655	Fini/Garfield 2000-2011.zip	to_parse
1656	Fini/The Umbrella Academy v08 - Hazel and Cha Cha Save Christmas.zip	to_parse
1657	Fini/The Autumnlands v01 - Tooth & Claw.zip	to_parse
1658	Fini/Sunstone v04.zip	to_parse
1659	Fini/Tomboy 01-06.zip	to_parse
1660	Fini/Postal v08 - Deliverance 01-04.zip	to_parse
1661	Fini/Hexed - The Harlot & The Thief v02.zip	to_parse
1663	Fini/The Manhattan Projects v04 - The Four Disciplines.cbz	to_parse
1664	Fini/Planet of the Apes/07. Exile on the Planet of the Apes.zip	to_parse
1665	Fini/Planet of the Apes/03. Planet of the Apes v03 - Children of Fire.zip	to_parse
1666	Fini/Planet of the Apes/05. Planet of the Apes v05 - The Utopians.zip	to_parse
1667	Fini/Planet of the Apes/06. Betrayal of the Planet of the Apes.zip	to_parse
1668	Fini/Planet of the Apes/04. Planet of the Apes v04 - The Half Man.zip	to_parse
1669	Fini/Planet of the Apes/10. Cataclysm v03.zip	to_parse
1670	Fini/Planet of the Apes/09. Cataclysm v02.zip	to_parse
1671	Fini/Planet of the Apes/01. Planet of the Apes v01.zip	to_parse
1672	Fini/Planet of the Apes/08. Cataclysm v01.zip	to_parse
1673	Fini/Planet of the Apes/11. Star Trek - Planet of the Apes - The Primate Directive.zip	to_parse
1674	Fini/Planet of the Apes/02. Planet of the Apes v02 - The Devil's Pawn.zip	to_parse
1675	Fini/The Fuse v04 - Constant Orbital Revolutions.zip	to_parse
1676	Fini/Morning Glories v10 - Expulsion.zip	to_parse
1677	Fini/The Fuse v02 - Gridlock.zip	to_parse
1678	Fini/The Black Hood/03. The Black Hood v03 - Season 2.zip	to_parse
1679	Fini/The Black Hood/01. The Black Hood v01 - The Bullet's Kiss.zip	to_parse
1680	Fini/The Black Hood/02. The Black Hood 07-11.zip	to_parse
1681	Fini/Regression 11-15 - Time is an Illusion.zip	to_parse
1682	Fini/Morning Glories v07 - Honors.zip	to_parse
1683	Fini/The Boys v04 - We Gotta Go Now.zip	to_parse
1684	Fini/Parker v01 - The Hunter.zip	to_parse
1685	Fini/Zero v03 - Tenderness of Wolves.zip	to_parse
1687	Fini/Invisible Republic/02. Invisible Republic v02.zip	to_parse
1688	Fini/Invisible Republic/01. Invisible Republic v01.zip	to_parse
1690	Fini/Royal City/02. Royal City 06-10 - Sonic Youth.zip	to_parse
1691	Fini/Royal City/03. Royal City 11-14 - We All Float On.zip	to_parse
1692	Fini/Royal City/01. Royal City v01 - Next of Kin.zip	to_parse
1693	Fini/Transmetropolitan v01 - Back On the Street.zip	to_parse
1694	Fini/Kill or be Killed v04.zip	to_parse
1695	Fini/DMZ v06 - Blood in the Game.zip	to_parse
1696	Fini/Crosswind 01-06.zip	to_parse
1697	Fini/Cryptocracy.zip	to_parse
1699	Fini/The Ghost Fleet/02. The Ghost Fleet 05-08.zip	to_parse
1700	Fini/Luther Strode - The Complete Series.cbz	to_parse
1701	Fini/Fatale v04 - Pray For Rain.zip	to_parse
1702	Fini/DMZ v01 - On the Ground.zip	to_parse
1703	Fini/Transmetropolitan v05 - Lonely City.zip	to_parse
1704	Fini/The Umbrella Academy v01 - The Umbrella Academy.zip	to_parse
1705	Fini/Who is Jake Ellis.zip	to_parse
1706	Fini/Postal v04.zip	to_parse
1707	Fini/The Sandman v07 - Brief Lives.zip	to_parse
1708	Fini/Give me Liberty.zip	to_parse
1709	Fini/The Goddamned 01-05.zip	to_parse
1710	Fini/FBP - Federal Bureau of Physics v02 - Wish You Were Here.zip	to_parse
1711	Fini/Velvet v02 - The Secret Lives of Dead Men.zip	to_parse
1712	Fini/Scalped - The Deluxe Edition Book 05.zip	to_parse
1713	Fini/The Sandman v01 - Preludes and Nocturnes.zip	to_parse
1714	Fini/The Fuse v01 - The Russia Shift.zip	to_parse
1715	Fini/The Walking Dead/30. The Walking Dead v25 - No Turning Back.zip	to_parse
1716	Fini/The Walking Dead/15. The Walking Dead v14 - No Way Out.zip	to_parse
1718	Fini/The Walking Dead/33. The Walking Dead v27 - The Whisperer War.zip	to_parse
1719	Fini/The Walking Dead/31. The Walking Dead Special - The Alien.zip	to_parse
1720	Fini/The Walking Dead/10. The Walking Dead v10 - What We Become.zip	to_parse
1721	Fini/The Walking Dead/20. The Walking Dead v18 - What Comes After.zip	to_parse
1722	Fini/The Walking Dead/38. The Walking Dead v31 - The Rotten Core.zip	to_parse
1723	Fini/The Walking Dead/21. The Walking Dead - The Governor Special.zip	to_parse
1724	Fini/The Walking Dead/27. The Walking Dead v22 - A New Beginning.zip	to_parse
1725	Fini/The Walking Dead/01. The Walking Dead v01 - Days Gone Bye.zip	to_parse
1726	Fini/The Walking Dead/02. The Walking Dead v02 - Miles Behind Us.zip	to_parse
1727	Fini/The Walking Dead/16. The Walking Dead v15 - We Find Ourselves.zip	to_parse
1728	Fini/The Walking Dead/22. The Walking Dead v19 - March To War.zip	to_parse
1729	Fini/The Walking Dead/11. The Walking Dead v11 - Fear the Hunters.zip	to_parse
1730	Fini/The Walking Dead/14. The Walking Dead Survivors' Guide.zip	to_parse
1731	Fini/The Walking Dead/04. The Walking Dead v04 - The Heart's Desire.zip	to_parse
1732	Fini/The Walking Dead/09. The Walking Dead v09 - Here We Remain.zip	to_parse
1733	Fini/The Walking Dead/34. The Walking Dead v28 - A Certain Doom.zip	to_parse
1734	Fini/The Walking Dead/19. The Walking Dead v17 - Something To Fear.cbz	to_parse
1735	Fini/The Walking Dead/12. The Walking Dead v12 - Life Among Them.zip	to_parse
1736	Fini/The Walking Dead/17. The Walking Dead v16 - A Larger World.zip	to_parse
1737	Fini/The Walking Dead/35. The Walking Dead - Here's Negan!.zip	to_parse
1738	Fini/The Walking Dead/29. The Walking Dead v24 - Life and Death.zip	to_parse
1739	Fini/The Walking Dead/18. The Walking Dead - Michonne Special.zip	to_parse
1740	Fini/The Walking Dead/36. The Walking Dead v29 - Lines We Cross.zip	to_parse
1741	Fini/The Walking Dead/03. The Walking Dead v03 - Safety Behind Bars.zip	to_parse
1742	Fini/The Walking Dead/05. The Walking Dead v05 - The Best Defense.zip	to_parse
1744	Fini/The Walking Dead/39. The Walking Dead v32 - Rest In Peace.zip	to_parse
1745	Fini/The Walking Dead/13. The Walking Dead v13 - Too Far Gone.zip	to_parse
1746	Fini/The Walking Dead/37. The Walking Dead v30 - New Word Order.zip	to_parse
1747	Fini/The Walking Dead/07. The Walking Dead v07 - The Calm Before.zip	to_parse
1748	Fini/The Walking Dead/23. The Walking Dead - Morgan Special.zip	to_parse
1749	Fini/The Walking Dead/28. The Walking Dead v23 - Whispers Into Screams.zip	to_parse
1750	Fini/The Walking Dead/25. The Walking Dead - Tyreese Special.zip	to_parse
1751	Fini/The Walking Dead/08. The Walking Dead v08 - Made To Suffer.zip	to_parse
1752	Fini/The Walking Dead/32. The Walking Dead v26 - Call To Arms.zip	to_parse
1753	Fini/The Walking Dead/26. The Walking Dead v21 - All Out War Part 2.zip	to_parse
1754	Fini/DMZ v10 - Collective Punishment.zip	to_parse
1755	Fini/The Autumnlands v02 - Woodland Creatures.zip	to_parse
1756	Fini/FBP - Federal Bureau of Physics v03 - Audeamus.zip	to_parse
1757	Fini/DMZ v02 - Body of A Journalist.zip	to_parse
1758	Fini/God Hates Astronauts v03 - Cosmic Apocalypse.zip	to_parse
1759	Fini/Cognetic.zip	to_parse
1760	Fini/Revival - Deluxe Collection v03.zip	to_parse
1761	Fini/Revival - Deluxe Collection v04.zip	to_parse
1762	Fini/Shutter v02 - Way of the World.zip	to_parse
1763	Fini/The Losers - Book Two.zip	to_parse
1764	Fini/Ghosted v02 - Books of the Dead.zip	to_parse
1765	Fini/Scalped - The Deluxe Edition Book 02.zip	to_parse
1766	Fini/FBP - Federal Bureau of Physics v04 - The End Times.zip	to_parse
1767	Fini/The Invisibles - The Deluxe Edition Book 03.cbz	to_parse
1768	Fini/The Boys v08 - Highland Laddie.zip	to_parse
1769	Fini/Red 01-03.zip	to_parse
1770	Fini/Sweet Tooth - The Deluxe Edition Book 03.zip	to_parse
1771	Fini/The Maxx/02. The Maxx 0.5.zip	to_parse
1772	Fini/The Maxx/09. The Maxx Maxximized v07.zip	to_parse
1773	Fini/The Maxx/01. The Maxx Maxximized v01.zip	to_parse
1774	Fini/The Maxx/03. The Maxx Maxximized v02.zip	to_parse
1775	Fini/The Maxx/10. Gen 13 - The Maxx.zip	to_parse
1777	Fini/The Maxx/11. Friends of Maxx 01-03.zip	to_parse
1779	Fini/The Maxx/05. Darker Image 01.zip	to_parse
1780	Fini/The Maxx/08. The Maxx Maxximized v06.zip	to_parse
1781	Fini/The Maxx/04. The Maxx Maxximized v03.zip	to_parse
1782	Fini/Scalped - The Deluxe Edition Book 03.zip	to_parse
1783	Fini/Transmetropolitan v02 - Lust For Life.zip	to_parse
1784	Fini/Regression 01-05 - Way Down Deep.zip	to_parse
1785	Fini/Peter Panzerfaust v01-02 - Deluxe Edition.zip	to_parse
1786	Fini/Charles Burn - Nitnit/03. Charles Burns - Sugar Skull.zip	to_parse
1787	Fini/Charles Burn - Nitnit/01. Charles Burns - X'ed Out.zip	to_parse
1788	Fini/Postal v01.zip	to_parse
1789	Fini/The Sandman v02 - The Doll's House.zip	to_parse
1790	Fini/Preacher - Book 03.zip	to_parse
1791	Fini/Shaolin Cowboy v03 - Who'll Stop the Reign.zip	to_parse
1792	Fini/Revival - Deluxe Collection v01.zip	to_parse
1793	Fini/The Invisibles - The Deluxe Edition Book 02.zip	to_parse
1794	Fini/Ex Machina - Book 01.zip	to_parse
1795	Fini/Transmetropolitan v09 - The Cure.zip	to_parse
1796	Fini/Letter 44 v01 - Escape Velocity.zip	to_parse
1797	Fini/DMZ v11 - Free States Rising.zip	to_parse
1798	Fini/Fatale v05 - Curse the Demon.zip	to_parse
1799	Fini/Sheltered v02.zip	to_parse
1800	Fini/Ex Machina - Book 05.zip	to_parse
1802	Fini/Evil Empire v02.zip	to_parse
1803	Fini/Zero v04 - Who by Fire.zip	to_parse
1804	Fini/Ex Machina - Book 04.zip	to_parse
1805	Fini/The Boys v12 - The Bloody Doors Off.zip	to_parse
1806	Fini/Chrononauts v02 - Futureshock.zip	to_parse
1807	Fini/The Sandman v09 - The Kindly Ones.zip	to_parse
1808	Fini/Shutter v01 - Wanderlost.zip	to_parse
1809	Fini/The Boys v05 - Herogasm.zip	to_parse
1810	Fini/The X-Files - Funko Universe.zip	to_parse
1811	Fini/The Umbrella Academy v02 - But the Past Ain't through with You.zip	to_parse
1812	Fini/Parker v04 - Slayground.zip	to_parse
1813	Fini/The Boys v11 - Over the Hill With the Swords of a Thousand Men.zip	to_parse
1814	Fini/The Sandman v08 - World's End.zip	to_parse
1815	Fini/Casanova v05 - Acedia 02.zip	to_parse
1816	Fini/We Can Never Go Home 01-05.zip	to_parse
1817	Fini/Sons of the Devil/01. Sons of the Devil v01.zip	to_parse
1819	Fini/Sons of the Devil/03. Sons of the Devil 11-14.zip	to_parse
1820	Fini/Nonplayer/Nonplayer 01.cbz	to_parse
1821	Fini/Nonplayer/Nonplayer 02.zip	to_parse
1822	Fini/Casanova v01 - Luxuria.zip	to_parse
1823	Fini/Fatale v01 - Death Chases Me.zip	to_parse
1824	Fini/John Flood.zip	to_parse
1825	Fini/The Saviors 01-05.zip	to_parse
1826	Fini/God Hates Astronauts v02 - A Star Is Born.zip	to_parse
1827	Fini/Hexed - The Harlot & The Thief v01.zip	to_parse
1828	Fini/Letter 44 v05 - Blueshift.zip	to_parse
1829	Fini/The Black Monday Murders/02. The Black Monday Murders 05-08.zip	to_parse
1830	Fini/The Black Monday Murders/01. The Black Monday Murders v01 - All Hail, God Mammon.zip	to_parse
1831	Fini/The Losers - Book One.zip	to_parse
1832	Fini/Men of Wrath 01-05.zip	to_parse
1833	Fini/Ex Machina - Book 03.zip	to_parse
1834	Fini/Reborn 01-06.zip	to_parse
1835	Fini/The Witcher/04. The Witcher - Of Flesh and Flame.zip	to_parse
1836	Fini/The Witcher/03. The Witcher - Library Edition v01.zip	to_parse
1837	Fini/The Witcher/01. The Witcher - Reasons of State.zip	to_parse
1838	Fini/The Witcher/02. The Witcher - Matters of Conscience.zip	to_parse
1839	Fini/Promethea/03. Promethea 19-25.zip	to_parse
1841	Fini/Promethea/04. Promethea 26-32.zip	to_parse
1842	Fini/Promethea/02. Promethea 13-18.zip	to_parse
1843	Fini/Drifter/01. Drifter v01 - Out of the Night.zip	to_parse
1844	Fini/Drifter/04. Drifter 15-20 - Remains.zip	to_parse
1845	Fini/Drifter/03. Drifter v03 - Lit by Fire.zip	to_parse
1846	Fini/Drifter/02. Drifter v02 - The Wake.zip	to_parse
1847	Fini/From Hell.zip	to_parse
1848	Fini/Hexed - The Harlot & The Thief v03.zip	to_parse
1849	Fini/The Boys v10 - Butcher, Baker, Candlestickmaker.zip	to_parse
1850	Fini/The Boys v07 - The Innocents.zip	to_parse
1851	Fini/Shaolin Cowboy v01 - Start Trek.zip	to_parse
1852	Fini/Ghosted v01 - Haunted Heist.zip	to_parse
1853	Fini/Transmetropolitan v03 - Year of the Bastard.zip	to_parse
1854	Fini/The Boys v01 - The Name of the Game.zip	to_parse
1855	Fini/The Sandman v05 - A Game Of You.zip	to_parse
1856	Fini/InSEXts Year One.zip	to_parse
1857	Fini/Roche Limit v03 - Monadic.zip	to_parse
1858	Fini/Letter 44 v06 - The End.zip	to_parse
1859	Fini/Bodies.zip	to_parse
1860	Fini/Morning Glories v04 - Truants.zip	to_parse
1861	Fini/Jupiter's Circle & Legacy/Jupiter's Circle/Jupiter's Circle v02.zip	to_parse
1862	Fini/Jupiter's Circle & Legacy/Jupiter's Circle/Jupiter's Circle v01.zip	to_parse
1863	Fini/Jupiter's Circle & Legacy/Jupiter's Legacy/Jupiter's Legacy v1.zip	to_parse
1865	Fini/Huck v01 - All-American.zip	to_parse
1866	Fini/Sheriff of Babylon - The Deluxe Edition.zip	to_parse
1867	Fini/DMZ v07 - War Powers.zip	to_parse
1868	Fini/Morning Glories v01 - For a Better Future.zip	to_parse
1869	Fini/Mage v02 - Book 01 - The Hero Discovered.zip	to_parse
1870	Fini/Savior.zip	to_parse
1871	Fini/Hacktivist v02.zip	to_parse
1872	Fini/Klaus v05 - Klaus and the Life and Times of Joe Christmas.zip	to_parse
1873	Fini/Unfollow v02 - God is Watching.zip	to_parse
1874	Fini/Kill or Be Killed v01.zip	to_parse
1876	Fini/The Dying and the Dead/The Dying and the Dead 01-03.zip	to_parse
1877	Fini/Negative Space.zip	to_parse
1878	Fini/Hacktivist v01.zip	to_parse
1879	Fini/Fatale v03 - West of Hell.zip	to_parse
1880	Fini/Garfield 1989-2000.zip	to_parse
1881	Fini/March - Book 2.zip	to_parse
1882	Fini/Sunstone v06.zip	to_parse
1883	Fini/Asterios Polyp.cbz	to_parse
1885	Fini/The Crow.zip	to_parse
1886	Fini/The Massive & Ninth Wave/05. The Massive v05 - Ragnarok.zip	to_parse
1887	Fini/The Massive & Ninth Wave/06. The Massive - Ninth Wave.zip	to_parse
1888	Fini/The Massive & Ninth Wave/02. The Massive v02 - Subcontinental.zip	to_parse
1889	Fini/The Massive & Ninth Wave/04. The Massive v04 - Sahara.zip	to_parse
1890	Fini/The Massive & Ninth Wave/03. The Massive v03 - Longship.zip	to_parse
1891	Fini/The Massive & Ninth Wave/01. The Massive v01 - Black Pacific.zip	to_parse
1892	Fini/Sons of Anarchy/07. Sons of Anarchy - Redwood Original v01.zip	to_parse
1893	Fini/Sons of Anarchy/05. Sons of Anarchy 19-22.zip	to_parse
1894	Fini/Sons of Anarchy/08. Sons of Anarchy - Redwood Original v02.zip	to_parse
1896	Fini/Sons of Anarchy/04. Sons of Anarchy 15-18.zip	to_parse
1897	Fini/Sons of Anarchy/02. Sons of Anarchy v02.zip	to_parse
1898	Fini/Sons of Anarchy/03. Sons of Anarchy 11-14.zip	to_parse
1899	Fini/Sons of Anarchy/01. Sons of Anarchy v01.zip	to_parse
1900	Fini/Sons of Anarchy/06. Sons of Anarchy 23-25.zip	to_parse
1901	Fini/Tumor.zip	to_parse
1902	Fini/Sheltered v01.zip	to_parse
1903	Fini/Transmetropolitan v04 - The New Scum.zip	to_parse
1904	Fini/Arcadia.zip	to_parse
1905	Fini/The Manhattan Projects v03.cbz	to_parse
1906	Fini/Shutter v03 - Quo Vadis.zip	to_parse
1907	Fini/Postal v07.zip	to_parse
1908	Fini/The New York Four & Five/01. The New York Four.zip	to_parse
1909	Fini/The New York Four & Five/02. The New York Five 01-04.zip	to_parse
1910	Fini/Peter Panzerfaust v05 - On 'Til Morning.zip	to_parse
1911	Fini/Parker v02 - The Outfit.zip	to_parse
1912	Fini/Transmetropolitan v07 - Spiders Thrash.zip	to_parse
1913	Fini/Local.zip	to_parse
1914	Fini/Klaus v03 - Klaus and the Crisis in Xmasville.zip	to_parse
1915	Fini/Casanova v04 - Acedia 01.zip	to_parse
1916	Fini/The Umbrella Academy v04 - Apocalypse Suite.zip	to_parse
1917	Fini/Burning Fields.zip	to_parse
1918	Fini/March - Book 1.zip	to_parse
1919	Fini/The United States of Murder Inc/02. United States vs. Murder, Inc. v01.zip	to_parse
1921	Fini/Copperhead/01. Copperhead v01 - A New Sheriff in Town.zip	to_parse
1922	Fini/Copperhead/04. Copperhead v04.zip	to_parse
1923	Fini/Copperhead/02. Copperhead v02.zip	to_parse
1924	Fini/Copperhead/03. Copperhead v03.zip	to_parse
1925	Fini/The Sixth Gun/01. The Sixth Gun v01 - Cold Dead Fingers.zip	to_parse
1926	Fini/The Sixth Gun/05. The Sixth Gun v05 - Winter Wolves.zip	to_parse
1927	Fini/The Sixth Gun/11. The Sixth Gun - Dust to Death.zip	to_parse
1928	Fini/The Sixth Gun/07. The Sixth Gun v06 - Ghost Dance.zip	to_parse
1929	Fini/The Sixth Gun/08. The Sixth Gun v07 - Not the Bullet, But the Fall.zip	to_parse
1930	Fini/The Sixth Gun/04. The Sixth Gun v04 - A Town Called Penance.zip	to_parse
1931	Fini/The Sixth Gun/03. The Sixth Gun v03 - Bound.cbz	to_parse
1932	Fini/The Sixth Gun/02. The Sixth Gun v02 - Crossroads.cbz	to_parse
1933	Fini/The Sixth Gun/12. The Sixth Gun v09 - Boot Hill.zip	to_parse
1934	Fini/The Sixth Gun/09. The Sixth Gun - Days of the Dead.zip	to_parse
1935	Fini/The Sixth Gun/10. The Sixth Gun v08 - Hell and High Water.zip	to_parse
1936	Fini/The Sixth Gun/06. The Sixth Gun - Sons of the Gun.zip	to_parse
1937	Fini/Sweet Tooth - The Deluxe Edition Book 01.zip	to_parse
1938	Fini/Postal v05.zip	to_parse
1939	Fini/The Manhattan Projects v02.cbz	to_parse
1940	Fini/Wytches/01. Wytches v01.zip	to_parse
1941	Fini/Wytches/02. Wytches - Bad Egg Halloween Special.zip	to_parse
1942	Fini/Morning Glories v06 - Demerits.zip	to_parse
1943	Fini/Clean Room v01 - Immaculate Conception.zip	to_parse
1944	Fini/Hit - 1955.zip	to_parse
1945	Fini/The Sandman v03 - Dream Country.zip	to_parse
1946	Fini/Casanova v03 - Avaritia.zip	to_parse
1947	Fini/Letter 44 v03 - Dark Matter.zip	to_parse
1948	Fini/Elephantmen & Hip Flask/Elephantmen/12. Elephantmen 2260 v05 - Up Close & Personal.zip	to_parse
1950	Fini/Elephantmen & Hip Flask/Elephantmen/14. Elephantmen - Goodnight Kiss.zip	to_parse
1951	Fini/Elephantmen & Hip Flask/Elephantmen/14. Elephantmen - Cover Stories.zip	to_parse
1952	Fini/Elephantmen & Hip Flask/Elephantmen/03. Elephantmen v02 - Fatal Diseases.zip	to_parse
1953	Fini/Elephantmen & Hip Flask/Elephantmen/09. Elephantmen 2260 v02 - The Red Queen.zip	to_parse
1954	Fini/Elephantmen & Hip Flask/Elephantmen/02. Elephantmen v01 - Wounded Animals Revised & Expanded.zip	to_parse
1955	Fini/Elephantmen & Hip Flask/Elephantmen/06. Elephantmen v05 - Devilish Functions.zip	to_parse
1956	Fini/Elephantmen & Hip Flask/Elephantmen/07. Elephantmen v06 - Earthly Desires.zip	to_parse
1957	Fini/Elephantmen & Hip Flask/Elephantmen/04. Elephantmen v03 - Dangerous Liaisons.zip	to_parse
1958	Fini/Elephantmen & Hip Flask/Elephantmen/11. Elephantmen 2260 v04 - All Coming Evil.zip	to_parse
1959	Fini/Elephantmen & Hip Flask/Elephantmen/08. Elephantmen 2260 v01 - Memories of the Future.zip	to_parse
1960	Fini/Elephantmen & Hip Flask/Elephantmen/10. Elephantmen 2260 v03 - Learning To Be Human.zip	to_parse
1961	Fini/Elephantmen & Hip Flask/Elephantmen/05. Elephantmen v04 - Questionable Things.zip	to_parse
2120	Fini/Morning Glories v09 - Assembly.zip	to_parse
1963	Fini/Elephantmen & Hip Flask/Elephantmen/14. Elephantmen - Shots.zip	to_parse
1964	Fini/Elephantmen & Hip Flask/Hip Flask/Hip Flask 04 - Ouroborous.zip	to_parse
1965	Fini/Elephantmen & Hip Flask/Hip Flask/Hip Flask 01 - Unnatural Selection.zip	to_parse
1966	Fini/Elephantmen & Hip Flask/Hip Flask/Hip Flask 02 - Elephantmen.zip	to_parse
1967	Fini/Elephantmen & Hip Flask/Hip Flask/Hip Flask 03 - Mystery City.zip	to_parse
1968	Fini/Ei8ht v01 - Outcast.zip	to_parse
1969	Fini/Wayward/05. Wayward 26-30 - Final Arc.zip	to_parse
1970	Fini/Wayward/01. Wayward - Deluxe Book 01.zip	to_parse
1971	Fini/Wayward/04. Wayward 21-25 - Tethered Souls.zip	to_parse
1972	Fini/Wayward/02. Wayward v03 - Out From the Shadows.zip	to_parse
1973	Fini/Wayward/03. Wayward 16-20 - Threads and Portents.zip	to_parse
1974	Fini/Bitch Planet v01 - Extraordinary Machine.zip	to_parse
1975	Fini/Preacher - Book 01.zip	to_parse
1976	Fini/Klaus v04 - Klaus and the Crying Snowman.zip	to_parse
1977	Fini/Return of the Dapper Men.cbz	to_parse
1978	Fini/Postal v03.zip	to_parse
1979	Fini/Coffin Hill v03 - Haunted Houses.zip	to_parse
1980	Fini/Unfollow v03 - Turn It Off.zip	to_parse
1981	Fini/Transmetropolitan v10 - One More Time.zip	to_parse
1982	Fini/Bitch Planet v02 - President Bitch.zip	to_parse
1984	Fini/Starve v02.zip	to_parse
1985	Fini/Judge Dredd - Funko Universe.zip	to_parse
1986	Fini/Cowboy Ninja Viking Deluxe Edition.zip	to_parse
1987	Fini/Roche Limit v01 - Anomalous.zip	to_parse
1988	Fini/Postal v02.zip	to_parse
1989	Fini/The Fade Out v02 - Act Two.zip	to_parse
1990	Fini/I Hate Fairyland/02. I Hate Fairyland v02 - Fluff My Life.zip	to_parse
1991	Fini/I Hate Fairyland/04. I Hate Fairyland v03 - Good Girl.zip	to_parse
1992	Fini/I Hate Fairyland/01. I Hate Fairyland v01 - Madly Ever After.zip	to_parse
1993	Fini/I Hate Fairyland/05. I Hate Fairyland v04 - Sadly Never After.zip	to_parse
1994	Fini/I Hate Fairyland/03. I Hate Image (FCBD 2017).zip	to_parse
1995	Fini/Clean Room v03 - Waiting for the Stars to Fall.zip	to_parse
1996	Fini/Postal v06.zip	to_parse
1997	Fini/Unfollow v01 - 140 Characters.zip	to_parse
1998	Fini/The Fade Out v03 - Act Three.zip	to_parse
1999	Fini/Bitch Planet v03 - Triple Feature.zip	to_parse
2000	Fini/DMZ v08 - Hearts and Minds.zip	to_parse
2001	Fini/The Umbrella Academy v07 - Hotel Oblivion 01-07.zip	to_parse
2002	Fini/The Umbrella Academy v05 - Anywhere But Here.zip	to_parse
2003	Fini/DMZ v03 - Public Works.zip	to_parse
2004	Fini/DMZ v09 - M.I.A.zip	to_parse
2005	Fini/Spread/01. Spread v01 - No Hope.zip	to_parse
2007	Fini/Spread/05. Spread 22-25 - Damocles.zip	to_parse
2008	Fini/Spread/03. Spread v03 - No Safe Place.zip	to_parse
2009	Fini/Spread/04. Spread 18-21 - Outside.zip	to_parse
2010	Fini/Death Vigil.zip	to_parse
2011	Fini/Invincible Tie-Ins/Extras/The Official Handbook of the Invincible Universe 02 (2007) (TheCaptain-DCP).cbz	to_parse
2012	Fini/Invincible Tie-Ins/Extras/Invincible Script Book 01 (2006) (MMS) (Shepherd+TheBastard).zip	to_parse
2014	Fini/Invincible Tie-Ins/Extras/The Official Handbook of the Invincible Universe 01 (of 02) (fixed) (2006) (Minutemen-Mr.Shepherd.zip	to_parse
2015	Fini/Invincible Tie-Ins/Atom Eve/Invincible Presents Atom Eve 02 (of 02) (2008) (Minutemen-TheDizzySaint).zip	to_parse
2016	Fini/Invincible Tie-Ins/Atom Eve/Invincible Presents Atom Eve 01 (of 02) (2008) (Minutemen-Zone).zip	to_parse
2017	Fini/Invincible Tie-Ins/Tech Jacket/Tech Jacket Vol. 1 - The Boy From Earth (2007) (Digital-Empire).cbz	to_parse
2018	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 005 (2008).zip	to_parse
2019	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 007 (2008).zip	to_parse
2020	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 004 (2008).zip	to_parse
2021	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 009 (2008).zip	to_parse
2022	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 011 (2009).zip	to_parse
2023	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 008 (2008).zip	to_parse
2024	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 006 (2008).zip	to_parse
2025	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit - Volume One - Old Soldier TPB (2007).zip	to_parse
2026	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 003 (2007).zip	to_parse
2027	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 001 (2007).cbz	to_parse
2028	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 012 (2009).zip	to_parse
2029	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 010 (2008).zip	to_parse
2030	Fini/Invincible Tie-Ins/Brit Complete Collection/Brit 002 (2007).cbz	to_parse
2031	Fini/Invincible Tie-Ins/Atom Eve & Rex Splode/Invincible Presents - Atom Eve & Rex Splode 001 (2009) (c2c) (Victorian-DCP).zip	to_parse
2032	Fini/Invincible Tie-Ins/Atom Eve & Rex Splode/Invincible Presents - Atom Eve & Rex Splode 002__2009___c2c___Victorian-DCP_.zip	to_parse
2033	Fini/Invincible Tie-Ins/Atom Eve & Rex Splode/Invincible Presents - Atom Eve & Rex Splode 003.zip	to_parse
2034	Fini/Invincible Tie-Ins/One Shots/Invincible Returns 001.zip	to_parse
2035	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/25 The Astounding Wolf-Man 024.cbz	to_parse
2036	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/13 The Astounding Wolf-Man 012.cbz	to_parse
2037	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/24 The Astounding Wolf-Man 023.zip	to_parse
2038	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/19 The Astounding Wolf-Man 018.cbz	to_parse
2039	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/23 The Astounding Wolf-Man 022.zip	to_parse
2040	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/20 The Astounding Wolf-Man 019.zip	to_parse
2041	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/22 The Astounding Wolf-Man 021.cbz	to_parse
2043	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/09 The Astounding Wolf-Man 009.zip	to_parse
2044	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/10 The Astounding Wolf-Man 010.cbz	to_parse
2045	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/07 The Astounding Wolf-Man 007.cbz	to_parse
2046	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/02 The Astounding Wolf-Man 002.cbz	to_parse
2047	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/17 The Astounding Wolf-Man 016.zip	to_parse
2048	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/16 The Astounding Wolf-Man 015.zip	to_parse
2049	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/15 The Astounding Wolf-Man 014.cbz	to_parse
2050	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/08 The Astounding Wolf-Man 008.zip	to_parse
2051	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/26 The Astounding Wolf-Man 025.zip	to_parse
2052	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/11 Invincible 057.zip	to_parse
2053	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/21 The Astounding Wolf-Man 020.cbz	to_parse
2054	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/06 The Astounding Wolf-Man 006.zip	to_parse
2055	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/14 The Astounding Wolf-Man 013.cbz	to_parse
2056	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/03 The Astounding Wolf-Man 003.cbz	to_parse
2057	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/12 The Astounding Wolf-Man 011.cbz	to_parse
2058	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/18 The Astounding Wolf-Man 017.cbz	to_parse
2060	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/01 The Astounding Wolf-Man 001.zip	to_parse
2061	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 002 (2013) (Digital) (Darkness-Empire).zip	to_parse
2062	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 007 (2013) (Digital) (Darkness-Empire).zip	to_parse
2063	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 005 (2013) (Digital) (Darkness-Empire).zip	to_parse
2064	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 004 (2013) (Digital) (Darkness-Empire).zip	to_parse
2065	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 008 (2013) (Digital) (Darkness-Empire).zip	to_parse
2066	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 001 (2013) (Digital) (Darkness-Empire).zip	to_parse
2067	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 003 (2013) (Digital) (Darkness-Empire).zip	to_parse
2068	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 009 (2014) (Digital) (Darkness-Empire).zip	to_parse
2069	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 010 (2014) (Digital) (Darkness-Empire).zip	to_parse
2070	Fini/Invincible Tie-Ins/Invincible Universe/Invincible Universe 006 (2013) (Digital) (Darkness-Empire).zip	to_parse
2071	Fini/Scalped - The Deluxe Edition Book 04.zip	to_parse
2072	Fini/Evil Empire v01 - We the People.zip	to_parse
2073	Fini/The Manhattan Projects v01 - Science Bad.zip	to_parse
2074	Fini/Irredeemable & Incorruptible/12. Irredeemable v06.zip	to_parse
2075	Fini/Irredeemable & Incorruptible/06. Incorruptible v02.zip	to_parse
2076	Fini/Irredeemable & Incorruptible/01. Irredeemable v01.zip	to_parse
2077	Fini/Irredeemable & Incorruptible/03. Irredeemable v03.zip	to_parse
2078	Fini/Irredeemable & Incorruptible/15. Irredeemable v09.zip	to_parse
2079	Fini/Irredeemable & Incorruptible/16. Incorruptible v07.zip	to_parse
2080	Fini/Irredeemable & Incorruptible/09. Incorruptible v04.zip	to_parse
2081	Fini/Irredeemable & Incorruptible/02. Irredeemable v02.zip	to_parse
2082	Fini/Irredeemable & Incorruptible/13. Incorruptible v06.zip	to_parse
2083	Fini/Irredeemable & Incorruptible/14. Irredeemable v08.zip	to_parse
2084	Fini/Irredeemable & Incorruptible/11. Irredeemable v07.zip	to_parse
2085	Fini/Irredeemable & Incorruptible/08. Irredeemable v05.zip	to_parse
2086	Fini/Irredeemable & Incorruptible/10. Incorruptible v05.zip	to_parse
2087	Fini/Irredeemable & Incorruptible/07. Incorruptible v03.zip	to_parse
2088	Fini/Irredeemable & Incorruptible/05. Incorruptible v01.zip	to_parse
2089	Fini/Irredeemable & Incorruptible/04. Irredeemable v04.zip	to_parse
2090	Fini/Irredeemable & Incorruptible/17. Irredeemable v10.zip	to_parse
2091	Fini/Kill or Be Killed v02.zip	to_parse
2092	Fini/Zero v02 - At the Heart of It All.zip	to_parse
2093	Fini/The Ghost Fleet - The Whole Goddamned Thing.zip	to_parse
2094	Fini/Fatale v02 - The Devils Business.zip	to_parse
2095	Fini/Sweet Tooth - The Deluxe Edition Book 02.zip	to_parse
2096	Fini/Sheltered v03.zip	to_parse
2097	Fini/DMZ v05 - The Hidden War.zip	to_parse
2098	Fini/Chrononauts v01.zip	to_parse
2100	Fini/Coffin Hill v02 - Dark Endeavors.zip	to_parse
2101	Fini/Sunstone v03.zip	to_parse
2102	Fini/Preacher - Book 05.zip	to_parse
2103	Fini/The Boys v09 - The Big Ride.zip	to_parse
2104	Fini/Redlands/Redlands 01-06.zip	to_parse
2105	Fini/Letter 44 v02 - Redshift.zip	to_parse
2106	Fini/Parker v03 - The Score.zip	to_parse
2107	Fini/Nameless.zip	to_parse
2108	Fini/The Fuse v03 - Perihelion.zip	to_parse
2109	Fini/Thief of Thieves/01. Thief of Thieves v01 - I Quit.zip	to_parse
2110	Fini/Thief of Thieves/07. Thief of Thieves 38-43.zip	to_parse
2111	Fini/Thief of Thieves/03. Thief of Thieves v03 - Venice.zip	to_parse
2112	Fini/Thief of Thieves/05. Thief of Thieves v05 - Take Me.zip	to_parse
2113	Fini/Thief of Thieves/02. Thief of Thieves v02 - Help Me.zip	to_parse
2114	Fini/Thief of Thieves/04. Thief of Thieves v04 - The Hit List.zip	to_parse
2115	Fini/Thief of Thieves/06. Thief of Thieves v06 - Gold Rush.zip	to_parse
2116	Fini/Memetic.zip	to_parse
2117	Fini/Shutter v05 - So Far Beyond.zip	to_parse
2118	Fini/Tomboy 07-12.zip	to_parse
2119	Fini/Ex Machina - Book 02.zip	to_parse
2123	Fini/Morning Glories v08 - Rivals.zip	to_parse
2124	Fini/Roche Limit v02 - Clandestiny.zip	to_parse
2125	Fini/Shutter v04 - All Roads.zip	to_parse
2126	Fini/Empire v02 - Uprising.zip	to_parse
2127	Fini/Clean Room v02 - Exile.zip	to_parse
2128	Fini/Regression 06-10 - Disciples.zip	to_parse
2129	Fini/DMZ v12 - The Five Nations of New York.zip	to_parse
2130	Fini/Velvet v01 - Before The Living End.zip	to_parse
2131	Fini/WE3.zip	to_parse
2133	Fini/Planetary/01. Planetary v01 - All Over the World and Other Stories.zip	to_parse
2134	Fini/Planetary/04. Planetary - Crossing Worlds.zip	to_parse
2135	Fini/Planetary/03. Planetary v03 - Leaving the 20th Century.zip	to_parse
2136	Fini/Planetary/02. Planetary v02 - The Fourth Man.zip	to_parse
2137	Fini/Mage v04 - Book 02 - The Hero Defined.zip	to_parse
2138	Fini/The Umbrella Academy v03 - Safe & Sound.zip	to_parse
2139	Fini/Mage v05 - Book 03 - The Hero Denied.zip	to_parse
2140	Fini/Deadly Class- Killer Set (FCBD Special).zip	to_parse
2141	Hellboy & BPRD/221 - B.P.R.D. - Hell on Earth - The Pickens County Horror 1.cbz	to_parse
2142	Hellboy & BPRD/037 - Weird Tales 2.zip	to_parse
2143	Hellboy & BPRD/139 - The Wild Hunt 08.cbz	to_parse
2144	Hellboy & BPRD/130 - Black Goddess 04.zip	to_parse
2145	Hellboy & BPRD/061 - BPRD - The Dead 02.zip	to_parse
2146	Hellboy & BPRD/145 - Abe Sapien - The Haunted Boy 01.cbz	to_parse
2147	Hellboy & BPRD/079 - BPRD - The Universal Machine 03.cbz	to_parse
2148	Hellboy & BPRD/114 - BPRD - The Ectoplasmic Man 01.zip	to_parse
2149	Hellboy & BPRD/009 - The Chained Coffin.zip	to_parse
2150	Hellboy & BPRD/241 - B.P.R.D. - 1948 3.zip	to_parse
2151	Hellboy & BPRD/216 - Lobster Johnson - The Burning Hand 5.zip	to_parse
2152	Hellboy & BPRD/132 - The Wild Hunt 01.zip	to_parse
2154	Hellboy & BPRD/192 - B.P.R.D. Casualties 1.zip	to_parse
2155	Hellboy & BPRD/060 - BPRD - The Dead 01.cbz	to_parse
2156	Hellboy & BPRD/029 - The Nature of the Beast.zip	to_parse
2157	Hellboy & BPRD/120 - The Crooked Man 03.zip	to_parse
2158	Hellboy & BPRD/042 - Weird Tales 4.zip	to_parse
2159	Hellboy & BPRD/001 - Hellboy Preview (Comics Buyer's Guide).zip	to_parse
2160	Hellboy & BPRD/088 - The Mole.zip	to_parse
2161	Hellboy & BPRD/062 - BPRD - The Dead 03.zip	to_parse
2162	Hellboy & BPRD/016 - A Christmas Underground.zip	to_parse
2163	Hellboy & BPRD/080 - BPRD - The Universal Machine 04.cbz	to_parse
2164	Hellboy & BPRD/074 - Hellboy - Makoma 01.cbz	to_parse
2165	Hellboy & BPRD/112 - Abe Sapien - The Drowning 05.zip	to_parse
2166	Hellboy & BPRD/134 - The Wild Hunt 03.zip	to_parse
2167	Hellboy & BPRD/032 - The Conqueror Worm.zip	to_parse
2168	Hellboy & BPRD/106 - BPRD - 1946 04.zip	to_parse
2169	Hellboy & BPRD/217 - Lobster Johnson - Tony Masso's Finest Hour.zip	to_parse
2170	Hellboy & BPRD/156 - Sir Edward Grey, Witchfinder - In the Service of Angels 02.cbz	to_parse
2171	Hellboy & BPRD/005 - The Wolves of Saint August.zip	to_parse
2172	Hellboy & BPRD/115 - BPRD - War On Frogs 01.zip	to_parse
2173	Hellboy & BPRD/173 - Hellboy - Beasts of Burden - Sacrifice.cbz	to_parse
2174	Hellboy & BPRD/102 - The Vampire of Prague.zip	to_parse
2175	Hellboy & BPRD/181 - Hellboy - Buster Oakley Gets His Wish 01.zip	to_parse
2176	Hellboy & BPRD/072 - BPRD - The Black Flame 05.zip	to_parse
2177	Hellboy & BPRD/006 - Madman Comics (1994) 005.zip	to_parse
2178	Hellboy & BPRD/033 - BPRD Hollow Earth.zip	to_parse
2179	Hellboy & BPRD/183 - B.P.R.D. - The Dead Remembered 02.cbz	to_parse
2180	Hellboy & BPRD/152 - Hellboy in Mexico 01.cbz	to_parse
2181	Hellboy & BPRD/208 - B.P.R.D. Hell on Earth - Russia 3.cbz	to_parse
2182	Hellboy & BPRD/118 - The Crooked Man 01.zip	to_parse
2183	Hellboy & BPRD/214 - Lobster Johnson - The Burning Hand 3.cbz	to_parse
2184	Hellboy & BPRD/075 - Hellboy - Makoma 02.zip	to_parse
2185	Hellboy & BPRD/056 - The Goon 07.zip	to_parse
2186	Hellboy & BPRD/117 - BPRD - War On Frogs 03.cbz	to_parse
2188	Hellboy & BPRD/148 - B.P.R.D. - King of Fear 02.cbz	to_parse
2189	Hellboy & BPRD/179 - BPRD - Hell on Earth - Gods 03.zip	to_parse
2190	Hellboy & BPRD/025 - Pancakes.zip	to_parse
2191	Hellboy & BPRD/204 - Abe Sapien - The Devil Does Not Jest 1.cbz	to_parse
2192	Hellboy & BPRD/041 - Dark Waters.zip	to_parse
2193	Hellboy & BPRD/085 - BPRD - Garden Of Souls 03.cbz	to_parse
2194	Hellboy & BPRD/194 - Hellboy - The Fury 2.cbz	to_parse
2195	Hellboy & BPRD/185 - Sir Edward Grey, Witchfinder - Lost and Gone Forever 01.cbz	to_parse
2196	Hellboy & BPRD/024 - Goodbye, Mr. Tod.zip	to_parse
2197	Hellboy & BPRD/110 - Abe Sapien - The Drowning 03.zip	to_parse
2198	Hellboy & BPRD/133 - The Wild Hunt 02.zip	to_parse
2199	Hellboy & BPRD/023 - The Varcolac.zip	to_parse
2200	Hellboy & BPRD/090 - Lobster Johnson - The Iron Prometheus (DCP Archive Edition).zip	to_parse
2201	Hellboy & BPRD/064 - BPRD - The Dead 05.zip	to_parse
2202	Hellboy & BPRD/212 - Lobster Johnson - The Burning Hand 1.cbz	to_parse
2203	Hellboy & BPRD/030 - King Vold.zip	to_parse
2204	Hellboy & BPRD/200 - Baltimore - The Curse Bells 3.cbz	to_parse
2205	Hellboy & BPRD/220 - B.P.R.D. - Hell on Earth - The Long Death 3.cbz	to_parse
2206	Hellboy & BPRD/098 - BPRD - Killing Ground 02.cbz	to_parse
2208	Hellboy & BPRD/140 - BPRD - 1947 01.cbz	to_parse
2209	Hellboy & BPRD/170 - B.P.R.D. - Hell on Earth - New World 03.zip	to_parse
2210	Hellboy & BPRD/128 - Black Goddess 02.zip	to_parse
2211	Hellboy & BPRD/210 - B.P.R.D. Hell on Earth - Russia 5.cbz	to_parse
2213	Hellboy & BPRD/028 - Abe Sapien vs. Science.zip	to_parse
2214	Hellboy & BPRD/233 - B.P.R.D. - Hell on Earth - The Return of the Master 01.zip	to_parse
2215	Hellboy & BPRD/059 - BPRD Another Day at the Office.zip	to_parse
2216	Hellboy & BPRD/078 - BPRD - The Universal Machine 02.zip	to_parse
2217	Hellboy & BPRD/193 - Hellboy - The Fury 1.cbz	to_parse
2218	Hellboy & BPRD/058 - The Troll-witch.zip	to_parse
2219	Hellboy & BPRD/013 - Wake the Devil.cbz	to_parse
2220	Hellboy & BPRD/227 - Baltimore - Dr. Leskovar's Remedy 1.zip	to_parse
2221	Hellboy & BPRD/069 - BPRD - The Black Flame 02.cbz	to_parse
2222	Hellboy & BPRD/068 - BPRD - The Black Flame 01.zip	to_parse
2223	Hellboy & BPRD/176 - Hellboy - The Sleeping and the Dead 02.cbz	to_parse
2224	Hellboy & BPRD/008 - Babe 2 #002.zip	to_parse
2225	Hellboy & BPRD/126 - The Warning 05.zip	to_parse
2226	Hellboy & BPRD/099 - BPRD - Killing Ground 03.cbz	to_parse
2227	Hellboy & BPRD/125 - The Warning 04.zip	to_parse
2228	Hellboy & BPRD/026 - Box Full of Evil.zip	to_parse
2229	Hellboy & BPRD/246 - Hellboy in Hell 3.zip	to_parse
2231	Hellboy & BPRD/189 - Sir Edward Grey, Witchfinder - Lost and Gone Forever 05.cbz	to_parse
2232	Hellboy & BPRD/083 - BPRD - Garden Of Souls 01.cbz	to_parse
2233	Hellboy & BPRD/007 - Babe 2 #001.zip	to_parse
2234	Hellboy & BPRD/163 - Baltimore - The Plague Ships 04.cbz	to_parse
2235	Hellboy & BPRD/043 - Dr. Carp's Experiment.zip	to_parse
2236	Hellboy & BPRD/226 - B.P.R.D. - Hell on Earth - The Devil's Engine 3.zip	to_parse
2237	Hellboy & BPRD/247 - Hellboy in Hell 4.zip	to_parse
2238	Hellboy & BPRD/086 - BPRD - Garden Of Souls 04.cbz	to_parse
2239	Hellboy & BPRD/230 - B.P.R.D. - Hell on Earth - Exorcism 2.zip	to_parse
2240	Hellboy & BPRD/036 - Weird Tales 1.zip	to_parse
2241	Hellboy & BPRD/065 - The Ghoul.zip	to_parse
2242	Hellboy & BPRD/124 - The Warning 03.zip	to_parse
2244	Hellboy & BPRD/205 - Abe Sapien - The Devil Does Not Jest 2.cbz	to_parse
2245	Hellboy & BPRD/143 - BPRD - 1947 04.cbz	to_parse
2246	Hellboy & BPRD/055 - Hellboy_Premiere_Edition.zip	to_parse
2247	Hellboy & BPRD/202 - Baltimore - The Curse Bells 5.cbz	to_parse
2248	Hellboy & BPRD/022 - Batman, Hellboy, Starman #2.zip	to_parse
2249	Hellboy & BPRD/160 - Baltimore - The Plague Ships 01.cbz	to_parse
2250	Hellboy & BPRD/011 - Ghost - Hellboy 01.zip	to_parse
2251	Hellboy & BPRD/057 - The Troll-witch.zip	to_parse
2252	Hellboy & BPRD/051 - B.P.R.D. - Plague of Frogs 02.cbz	to_parse
2253	Hellboy & BPRD/010 - The Corpse and The Iron Shoes.zip	to_parse
2254	Hellboy & BPRD/044 - Night Train.zip	to_parse
2255	Hellboy & BPRD/049 - Weird Tales 8.zip	to_parse
2256	Hellboy & BPRD/178 - BPRD - Hell on Earth - Gods 02.zip	to_parse
2257	Hellboy & BPRD/100 - BPRD - Killing Ground 04.cbz	to_parse
2258	Hellboy & BPRD/046 - There's Something Under My Bed.zip	to_parse
2259	Hellboy & BPRD/020 - The Right Hand of Doom.zip	to_parse
2260	Hellboy & BPRD/184 - B.P.R.D. - The Dead Remembered 03.cbz	to_parse
2261	Hellboy & BPRD/111 - Abe Sapien - The Drowning 04.zip	to_parse
2262	Hellboy & BPRD/164 - Baltimore - The Plague Ships 05.cbz	to_parse
2263	Hellboy & BPRD/250 - B.P.R.D. Hell on Earth 104 - The Abyss of Time 2.zip	to_parse
2264	Hellboy & BPRD/211 - An Unmarked Grave.zip	to_parse
2265	Hellboy & BPRD/201 - Baltimore - The Curse Bells 4.cbz	to_parse
2266	Hellboy & BPRD/249 - B.P.R.D. Hell on Earth 103 - The Abyss of Time 1.zip	to_parse
2267	Hellboy & BPRD/238 - Baltimore - The Play.zip	to_parse
2268	Hellboy & BPRD/209 - B.P.R.D. Hell on Earth - Russia 4.cbz	to_parse
2269	Hellboy & BPRD/093 - Darkness Calls 03.zip	to_parse
2270	Hellboy & BPRD/187 - Sir Edward Grey, Witchfinder - Lost and Gone Forever 03.cbz	to_parse
2271	Hellboy & BPRD/218 - B.P.R.D. - Hell on Earth - The Long Death 1.cbz	to_parse
2272	Hellboy & BPRD/002 - San Diego Comic Con Comics 2 (Aug 93).zip	to_parse
2273	Hellboy & BPRD/144 - BPRD - 1947 05.cbz	to_parse
2274	Hellboy & BPRD/087 - BPRD - Garden Of Souls 05.cbz	to_parse
2275	Hellboy & BPRD/240 - B.P.R.D. - 1948 2.zip	to_parse
2276	Hellboy & BPRD/018 - Painkiller Jane - Hellboy.zip	to_parse
2277	Hellboy & BPRD/222 - B.P.R.D. - Hell on Earth - The Pickens County Horror 2.cbz	to_parse
2278	Hellboy & BPRD/021 - Batman, Hellboy, Starman #1.zip	to_parse
2279	Hellboy & BPRD/039 - The Kabandha (RPG comic).zip	to_parse
2280	Hellboy & BPRD/121 - In The Chapel Of Moloch.zip	to_parse
2281	Hellboy & BPRD/171 - B.P.R.D. - Hell on Earth - New World 04.zip	to_parse
2282	Hellboy & BPRD/137 - The Wild Hunt 06.cbz	to_parse
2283	Hellboy & BPRD/040 - Weird Tales 3.zip	to_parse
2284	Hellboy & BPRD/174 - Hellboy - Double Feature of Evil 01.zip	to_parse
2285	Hellboy & BPRD/113 - Out of Reach.zip	to_parse
2286	Hellboy & BPRD/109 - Abe Sapien - The Drowning 02.zip	to_parse
2287	Hellboy & BPRD/004 - Seed of Destruction.cbz	to_parse
2289	Hellboy & BPRD/165 - Hellboy - The Storm 01.cbz	to_parse
2290	Hellboy & BPRD/195 - Hellboy - The Fury 3.zip	to_parse
2291	Hellboy & BPRD/161 - Baltimore - The Plague Ships 02.cbz	to_parse
2292	Hellboy & BPRD/239 - B.P.R.D. - 1948 1.zip	to_parse
2293	Hellboy & BPRD/231 - Lobster Johnson - The Prayer of Neferu.zip	to_parse
2294	Hellboy & BPRD/053 - B.P.R.D. - Plague of Frogs 04.cbz	to_parse
2295	Hellboy & BPRD/234 - B.P.R.D. - Hell on Earth - The Return of the Master 02.zip	to_parse
2296	Hellboy & BPRD/243 - B.P.R.D. - 1948 5.zip	to_parse
2297	Hellboy & BPRD/142 - BPRD - 1947 03.cbz	to_parse
2298	Hellboy & BPRD/096 - Darkness Calls 06.cbz	to_parse
2299	Hellboy & BPRD/034 - The Third Wish 1.zip	to_parse
2301	Hellboy & BPRD/045 - Weird Tales 5.zip	to_parse
2302	Hellboy & BPRD/101 - BPRD - Killing Ground 05.zip	to_parse
2303	Hellboy & BPRD/012 - Ghost - Hellboy 02.zip	to_parse
2304	Hellboy & BPRD/223 - B.P.R.D. - Hell on Earth - The Transformation of J. H. O Donnell 1.zip	to_parse
2305	Hellboy & BPRD/191 - Baltimore - Criminal Macabre FCBD.cbz	to_parse
2306	Hellboy & BPRD/073 - BPRD - The Black Flame 06.zip	to_parse
2307	Hellboy & BPRD/107 - BPRD - 1946 05.zip	to_parse
2308	Hellboy & BPRD/070 - BPRD - The Black Flame 03.zip	to_parse
2309	Hellboy & BPRD/197 - B.P.R.D. Hell on Earth - Monsters 2.cbz	to_parse
2310	Hellboy & BPRD/095 - Darkness Calls 05.zip	to_parse
2311	Hellboy & BPRD/225 - B.P.R.D. - Hell on Earth - The Devil's Engine 2.zip	to_parse
2312	Hellboy & BPRD/198 - Baltimore - The Curse Bells 1.cbz	to_parse
2313	Hellboy & BPRD/182 - B.P.R.D. - The Dead Remembered 01.cbz	to_parse
2314	Hellboy & BPRD/242 - B.P.R.D. - 1948 4.zip	to_parse
2315	Hellboy & BPRD/014 - Hellboy - Savage Dragon.zip	to_parse
2316	Hellboy & BPRD/047 - Weird Tales 6.zip	to_parse
2317	Hellboy & BPRD/215 - Lobster Johnson - The Burning Hand 4.cbz	to_parse
2318	Hellboy & BPRD/054 - B.P.R.D. - Plague Of Frogs 05.cbz	to_parse
2319	Hellboy & BPRD/141 - BPRD - 1947 02.cbz	to_parse
2321	Hellboy & BPRD/131 - Black Goddess 05.cbz	to_parse
2322	Hellboy & BPRD/151 - B.P.R.D. - King of Fear 05.cbz	to_parse
2323	Hellboy & BPRD/077 - BPRD - The Universal Machine 01.zip	to_parse
2324	Hellboy & BPRD/146 - Hellboy - The Bride of Hell 01.cbz	to_parse
2325	Hellboy & BPRD/135 - The Wild Hunt 04.cbz	to_parse
2326	Hellboy & BPRD/116 - BPRD - War On Frogs 02.zip	to_parse
2327	Hellboy & BPRD/147 - B.P.R.D. - King of Fear 01.cbz	to_parse
2328	Hellboy & BPRD/031 - Heads.zip	to_parse
2329	Hellboy & BPRD/190 - Hellboy - Being Human.cbz	to_parse
2330	Hellboy & BPRD/127 - Black Goddess 01.zip	to_parse
2331	Hellboy & BPRD/067 - Hellboy - The Island 02.zip	to_parse
2332	Hellboy & BPRD/168 - B.P.R.D. - Hell on Earth - New World 01.cbz	to_parse
2333	Hellboy & BPRD/017 - Abe Sapien - Drums of the Dead.zip	to_parse
2334	Hellboy & BPRD/157 - Sir Edward Grey, Witchfinder - In the Service of Angels 03.cbz	to_parse
2335	Hellboy & BPRD/228 - Baltimore - Dr. Leskovars Remedy 2.zip	to_parse
2336	Hellboy & BPRD/015 - Almost Colossus.zip	to_parse
2337	Hellboy & BPRD/175 - Hellboy - The Sleeping and the Dead 01.cbz	to_parse
2338	Hellboy & BPRD/224 - B.P.R.D. - Hell on Earth - The Devils Engine 1.zip	to_parse
2339	Hellboy & BPRD/071 - BPRD - The Black Flame 04.zip	to_parse
2340	Hellboy & BPRD/244 - Hellboy in Hell 1.zip	to_parse
2341	Hellboy & BPRD/166 - Hellboy - The Storm 02.cbz	to_parse
2342	Hellboy & BPRD/167 - Hellboy - The Storm 03.cbz	to_parse
2343	Hellboy & BPRD/048 - Weird Tales 7.zip	to_parse
2345	Hellboy & BPRD/050 - B.P.R.D. - Plague of Frogs 01.zip	to_parse
2346	Hellboy & BPRD/027 - The Killer in my Skull.zip	to_parse
2347	Hellboy & BPRD/153 - Abe Sapien - The Abyssal Plain 01.zip	to_parse
2348	Hellboy & BPRD/092 - Darkness Calls 02.zip	to_parse
2349	Hellboy & BPRD/123 - The Warning 02.zip	to_parse
2350	Hellboy & BPRD/081 - BPRD - The Universal Machine 05.zip	to_parse
2351	Hellboy & BPRD/097 - BPRD - Killing Ground 01.cbz	to_parse
2352	Hellboy & BPRD/199 - Baltimore - The Curse Bells 2.cbz	to_parse
2353	Hellboy & BPRD/237 - B.P.R.D. - Hell on Earth  - The Return of the Master 102.zip	to_parse
2354	Hellboy & BPRD/063 - BPRD - The Dead 04.zip	to_parse
2355	Hellboy & BPRD/103 - BPRD - 1946 01.zip	to_parse
2356	Hellboy & BPRD/159 - Sir Edward Grey, Witchfinder - In the Service of Angels 05.cbz	to_parse
2357	Hellboy & BPRD/019 - The Baba Yaga.zip	to_parse
2358	Hellboy & BPRD/035- The Third Wish 2.zip	to_parse
2359	Hellboy & BPRD/236 - B.P.R.D. - Hell on Earth - The Return of the Master 101.zip	to_parse
2360	Hellboy & BPRD/003 - Next Men #21.zip	to_parse
2361	Hellboy & BPRD/038 - The Soul of Venice.zip	to_parse
2362	Hellboy & BPRD/149 - B.P.R.D. - King of Fear 03.cbz	to_parse
2363	Hellboy & BPRD/219 - B.P.R.D. - Hell on Earth - The Long Death 2.cbz	to_parse
2364	Hellboy & BPRD/Hellboy, Jr/The Amazing Screw-On Head.zip	to_parse
2365	Hellboy & BPRD/Hellboy, Jr/Hellboy Jr. Gets a Car.cbz	to_parse
2366	Hellboy & BPRD/Hellboy, Jr/The Golden Army.zip	to_parse
2367	Hellboy & BPRD/Hellboy, Jr/Hellboy Jr. 01.zip	to_parse
2368	Hellboy & BPRD/Hellboy, Jr/Hellboy Jr. Halloween Special.zip	to_parse
2369	Hellboy & BPRD/Hellboy, Jr/Pancakes.zip	to_parse
2370	Hellboy & BPRD/Hellboy, Jr/Hellboy Jr. 02.zip	to_parse
2371	Hellboy & BPRD/129 - Black Goddess 03.cbz	to_parse
2372	Hellboy & BPRD/082 - Animated - The Black Wedding.zip	to_parse
2374	Hellboy & BPRD/177 - BPRD - Hell on Earth - Gods 01.zip	to_parse
2375	Hellboy & BPRD/094 - Darkness Calls 04.zip	to_parse
2376	Hellboy & BPRD/122 - The Warning 01.zip	to_parse
2377	Hellboy & BPRD/136 - The Wild Hunt 05.cbz	to_parse
2378	Hellboy & BPRD/076 - The Hydra and the Lion.zip	to_parse
2379	Hellboy & BPRD/104 - BPRD - 1946 02.zip	to_parse
2380	Hellboy & BPRD/108 - Abe Sapien - The Drowning 01.zip	to_parse
2381	Hellboy & BPRD/162 - Baltimore - The Plague Ships 03.cbz	to_parse
2382	Hellboy & BPRD/203 - Hellboy Versus The Aztec Mummy.zip	to_parse
2383	Hellboy & BPRD/245 - Hellboy in Hell 2.zip	to_parse
2384	Hellboy & BPRD/213 - Lobster Johnson - The Burning Hand 2.cbz	to_parse
2385	Hellboy & BPRD/091 - Darkness Calls 01.zip	to_parse
2386	Hellboy & BPRD/119 - The Crooked Man 02.zip	to_parse
2387	Hellboy & BPRD/180 - BPRD - Hell on Earth - Seattle 01.cbz	to_parse
2389	Hellboy & BPRD/155 - Sir Edward Grey, Witchfinder - In the Service of Angels 01.cbz	to_parse
2390	Hellboy & BPRD/138 - The Wild Hunt 07.cbz	to_parse
2391	Hellboy & BPRD/207 - B.P.R.D. Hell on Earth - Russia 2.cbz	to_parse
2392	Hellboy & BPRD/066 - Hellboy - The Island 01.cbz	to_parse
2393	Hellboy & BPRD/105 - BPRD - 1946 03.zip	to_parse
2394	Hellboy & BPRD/248 - Baltimore - Widow and the Tank.zip	to_parse
2395	Hellboy & BPRD/206 - B.P.R.D. Hell on Earth - Russia 1.cbz	to_parse
2396	Hellboy & BPRD/172 - B.P.R.D. - Hell on Earth - New World 05.zip	to_parse
2397	Hellboy & BPRD/154 - Abe Sapien - The Abyssal Plain 02.cbz	to_parse
2398	Ongoing/Manifest Destiny/06. Manifest Destiny 31-36 - Fortis & Invisibilia.zip	to_parse
2399	Ongoing/Manifest Destiny/01. Manifest Destiny v01 - Flora & Fauna.zip	to_parse
2401	Ongoing/Manifest Destiny/07. Manifest Destiny 37-42 - Talpa Lumbricus & Lepus.zip	to_parse
2402	Ongoing/Manifest Destiny/04. Manifest Destiny 19-24 - Sasquatch.zip	to_parse
2403	Ongoing/Manifest Destiny/02. Manifest Destiny v02 - Amphibia & Insecta.zip	to_parse
2404	Ongoing/Manifest Destiny/03. Manifest Destiny v03 - Chiroptera & Carniformaves.zip	to_parse
2405	Ongoing/Ghostbusters/08. Ghostbusters v01.zip	to_parse
2406	Ongoing/Ghostbusters/02. Ghostbusters - Displaced Aggression.zip	to_parse
2407	Ongoing/Ghostbusters/31. Ghostbusters 35th Anniversary - Answer the Call.zip	to_parse
2408	Ongoing/Ghostbusters/28. Ghostbusters - Crossing Over.zip	to_parse
2409	Ongoing/Ghostbusters/05. Ghostbusters - Con-Volution.zip	to_parse
2410	Ongoing/Ghostbusters/07. Infestation.zip	to_parse
2411	Ongoing/Ghostbusters/21. Ghostbusters International v01.zip	to_parse
2412	Ongoing/Ghostbusters/06. Ghostbusters - What In Samhain Just Happened.zip	to_parse
2413	Ongoing/Ghostbusters/01. Ghostbusters - The Other Side.zip	to_parse
2414	Ongoing/Ghostbusters/25. Ghostbusters - Funko Universe.zip	to_parse
2415	Ongoing/Ghostbusters/26. Ghostbusters - Answer the Call 01-05.zip	to_parse
2416	Ongoing/Ghostbusters/32. Ghostbusters 35th Anniversary - Extreme.zip	to_parse
2417	Ongoing/Ghostbusters/16. Ghostbusters v09.zip	to_parse
2418	Ongoing/Ghostbusters/15. Ghostbusters v08.zip	to_parse
2419	Ongoing/Ghostbusters/34. Transformers - Ghostbusters 01-05.zip	to_parse
2420	Ongoing/Ghostbusters/09. Ghostbusters v02.zip	to_parse
2421	Ongoing/Ghostbusters/24. Ghostbusters 101 01-06.zip	to_parse
2422	Ongoing/Ghostbusters/19. Ghostbusters - Annual 2015.zip	to_parse
2423	Ongoing/Ghostbusters/13. Ghostbusters v06.zip	to_parse
2424	Ongoing/Ghostbusters/12. Ghostbusters v05.zip	to_parse
2425	Ongoing/Ghostbusters/04. Ghostbusters - Tainted Love.zip	to_parse
2426	Ongoing/Ghostbusters/30. Ghostbusters 35th Anniversary.zip	to_parse
2427	Ongoing/Ghostbusters/29. Ghostbusters 20-20.zip	to_parse
2428	Ongoing/Ghostbusters/23. Ghostbusters - Annual 2017.zip	to_parse
2429	Ongoing/Ghostbusters/33. Ghostbusters 35th Anniversary - The Real Ghostbusters.zip	to_parse
2430	Ongoing/Ghostbusters/03. Ghostbusters - Past, Present, and Future.zip	to_parse
2431	Ongoing/Ghostbusters/10. Ghostbusters v03.zip	to_parse
2432	Ongoing/Ghostbusters/14. Ghostbusters v07.zip	to_parse
2433	Ongoing/Ghostbusters/22. Ghostbusters International v02.zip	to_parse
2434	Ongoing/Ghostbusters/11. Ghostbusters v04.zip	to_parse
2435	Ongoing/Ghostbusters/20. Ghostbusters - Deviations.zip	to_parse
2436	Ongoing/Ghostbusters/18. Ghostbusters - Get Real.zip	to_parse
2437	Ongoing/Low/Low v03 - Shore of the Dying Light.zip	to_parse
2438	Ongoing/Low/Low v01 - The Delirium of Hope.zip	to_parse
2440	Ongoing/Low/Low v04 - Outer Aspects of Inner Attitudes.zip	to_parse
2441	Ongoing/Teenage Mutant Ninja Turtles/Kevin Eastman's Teenage Mutant Ninja Turtles Artobiography.zip	to_parse
2442	Ongoing/Teenage Mutant Ninja Turtles/03. Dreamwave/Teenage Mutant Ninja Turtles - Dreamwave 01-07.zip	to_parse
2443	Ongoing/Teenage Mutant Ninja Turtles/Teenage Mutant Ninja Turtles - Funko Universe.zip	to_parse
2445	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1987 - Tales of the TNMT vol 1/Tales of the Teenage Mutant Ninja Turtles v02.cbz	to_parse
2446	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 30.zip	to_parse
2447	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 38.zip	to_parse
2448	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  59.zip	to_parse
2449	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 42.zip	to_parse
2450	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the Teenage Mutant Ninja Turtles v06.zip	to_parse
2451	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the Teenage Mutant Ninja Turtles v05.zip	to_parse
2452	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  70.zip	to_parse
2453	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  62.zip	to_parse
2454	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 31.zip	to_parse
2455	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  67.zip	to_parse
2456	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 28.cbz	to_parse
2457	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  51.zip	to_parse
2458	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  64.zip	to_parse
2459	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  57.zip	to_parse
2461	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 32.zip	to_parse
2462	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 45.zip	to_parse
2463	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 48.zip	to_parse
2464	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  54.zip	to_parse
2465	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 35.zip	to_parse
2466	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 27.cbz	to_parse
2467	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 37.zip	to_parse
2468	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 36.zip	to_parse
2469	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  68.zip	to_parse
2470	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 43.zip	to_parse
2472	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the Teenage Mutant Ninja Turtles v08.zip	to_parse
2473	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  58.zip	to_parse
2474	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 26.cbz	to_parse
2475	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the Teenage Mutant Ninja Turtles v07.zip	to_parse
2476	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 44.zip	to_parse
2477	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  69.zip	to_parse
2478	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  63.zip	to_parse
2479	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  53.zip	to_parse
2480	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the Teenage Mutant Ninja Turtles v04.zip	to_parse
2481	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 21.zip	to_parse
2482	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 29.zip	to_parse
2483	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 33.zip	to_parse
2484	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 50.zip	to_parse
2485	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 49.zip	to_parse
2486	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 41.zip	to_parse
2487	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  66.zip	to_parse
2488	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  55.zip	to_parse
2489	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  52.zip	to_parse
2490	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 40.zip	to_parse
2491	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 47.zip	to_parse
2492	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 46.zip	to_parse
2493	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  65.zip	to_parse
2494	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  60.zip	to_parse
2495	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 39.zip	to_parse
2496	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNT v2 34.zip	to_parse
2497	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the Teenage Mutant Ninja Turtles v03.cbz	to_parse
2498	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1996 - Vol 2.5 - Bodycount/TMNT - Bodycount.zip	to_parse
2499	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/19 Various Newspaper Strips.zip	to_parse
2500	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Plastron Cafe 02.cbz	to_parse
2501	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Gizmo 05.zip	to_parse
2502	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Mirage Minicomics - A Forgotten TMNT Adventure.zip	to_parse
2503	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Raphael Extras.zip	to_parse
2504	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Gizmo and the Fugitoid 01.zip	to_parse
2505	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Plastron Cafe 03.zip	to_parse
2506	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Tales of Leonardo - Blind Sight 02.zip	to_parse
2507	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/The Maltese Turtle.zip	to_parse
2508	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Tales of Leonardo - Blind Sight 04.zip	to_parse
2509	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Goobledygook v02.zip	to_parse
2510	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Casey Jones and Raphael.zip	to_parse
2511	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Michaelangelo Christmas Special.zip	to_parse
2512	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Gizmo 04.zip	to_parse
2513	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Gizmo 06.zip	to_parse
2514	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Plastron Cafe 01.cbz	to_parse
2515	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Fugitoid.cbz	to_parse
2517	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Toys R Us Exclusive.cbz	to_parse
2519	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Gizmo and the Fugitoid 02.zip	to_parse
2520	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Turtle Soup v02 04.cbz	to_parse
2521	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Mirage Minicomics - Gizmo.zip	to_parse
2522	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Tales of Leonardo - Blind Sight 01.zip	to_parse
2523	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Tales of Leonardo - Blind Sight 03.zip	to_parse
2524	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Turtle Soup v01.zip	to_parse
2525	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Turtlemania Special.zip	to_parse
2526	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Gizmo 02.zip	to_parse
2527	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Gizmo 01.zip	to_parse
2528	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Grunts.zip	to_parse
2530	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Raphael - Bad Moon Rising 01.zip	to_parse
2531	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Mirage Minicomics - Dead Biker and Gutsucker.zip	to_parse
2532	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Mirage Minicomics - Casey Jones, Private Eye.zip	to_parse
2533	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/The Haunted Pizza.zip	to_parse
2534	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Times Pipeline.cbz	to_parse
2535	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Gizmo 03.zip	to_parse
2536	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Raphael - Bad Moon Rising 04.zip	to_parse
2537	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Raphael - Bad Moon Rising 02.zip	to_parse
2538	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 07.zip	to_parse
2539	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 13.zip	to_parse
2540	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 03.zip	to_parse
2541	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 20.zip	to_parse
2542	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 30.zip	to_parse
2543	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 06.zip	to_parse
2544	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 25.zip	to_parse
2545	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 22.zip	to_parse
2546	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 27.zip	to_parse
2547	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 08.zip	to_parse
2548	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 05.zip	to_parse
2549	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 24.zip	to_parse
2550	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 31.zip	to_parse
2551	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 09.zip	to_parse
2552	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 02.zip	to_parse
2553	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 29.zip	to_parse
2554	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 16.zip	to_parse
2555	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 17.zip	to_parse
2556	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 28.zip	to_parse
2557	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 11.zip	to_parse
2558	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 12.zip	to_parse
2559	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 18.cbz	to_parse
2560	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 32.zip	to_parse
2562	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 04.zip	to_parse
2563	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 21.zip	to_parse
2564	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 01.zip	to_parse
2565	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 10.zip	to_parse
2566	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 23.zip	to_parse
2567	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 26.zip	to_parse
2568	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 19.zip	to_parse
2569	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 15.zip	to_parse
2570	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/02. Teenage Mutant Ninja Turtles - The Ultimate B&W Collection v02.zip	to_parse
2571	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/06. Teenage Mutant Ninja Turtles - Classics v02.zip	to_parse
2572	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/07. Teenage Mutant Ninja Turtles v1 24-26.zip	to_parse
2573	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/08. Teenage Mutant Ninja Turtles - Classics v03.zip	to_parse
2574	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/09. Teenage Mutant Ninja Turtles v1 30.zip	to_parse
2575	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/10. Teenage Mutant Ninja Turtles - Classics v04.zip	to_parse
2576	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/13. Teenage Mutant Ninja Turtles v1 41.zip	to_parse
2577	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/03. Teenage Mutant Ninja Turtles - Classics v01.zip	to_parse
2579	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/17. Teenage Mutant Ninja Turtles - The Ultimate B&W Collection v05.zip	to_parse
2580	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/14. Teenage Mutant Ninja Turtles - Classics v06.zip	to_parse
2581	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/01. Teenage Mutant Ninja Turtles - The Ultimate B&W Collection v01.zip	to_parse
2705	Ongoing/Black Hammer/02. Black Hammer - Giant-Sized Annual.zip	to_parse
2583	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/05. Teenage Mutant Ninja Turtles v1 18.zip	to_parse
2584	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/18. Teenage Mutant Ninja Turtles - The Ultimate B&W Collection v06.zip	to_parse
2585	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/12. Teenage Mutant Ninja Turtles - Classics v05.zip	to_parse
2586	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/11. Teenage Mutant Ninja Turtles Legends - Soul's Winter.zip	to_parse
2587	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/15. Teenage Mutant Ninja Turtles - Classics v07.zip	to_parse
2589	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1993 - Vol 2/Teenage Mutant Ninja Turtles - Classics v10.zip	to_parse
2590	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1993 - Vol 2/Teenage Mutant Ninja Turtles - Classics v08.zip	to_parse
2591	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1993 - Vol 2/Teenage Mutant Ninja Turtles - Classics v08/Teenage Mutant Ninja Turtles - Classics v08.zip	to_parse
2592	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1993 - Vol 2/Teenage Mutant Ninja Turtles - Classics v09.zip	to_parse
2593	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1993 - Vol 2/Teenage Mutant Ninja Turtles - Classics v10/Teenage Mutant Ninja Turtles - Classics v10.zip	to_parse
2594	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1996 - Vol 3/Teenage Mutant Ninja Turtles v3 25.zip	to_parse
2595	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1996 - Vol 3/Teenage Mutant Ninja Turtles v3 23.zip	to_parse
2596	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1996 - Vol 3/Teenage Mutant Ninja Turtles v3 24.zip	to_parse
2597	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/26. Mutanimals.zip	to_parse
2598	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/38. TMNT Universe 05 Main Story - Urban Legends.zip	to_parse
2599	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/85. Teenage Mutant Ninja Turtles - 20-20.zip	to_parse
2600	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/45. TMNT Universe 10 Back-up - Teenage Mutant Ninja Pepperoni.zip	to_parse
2601	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/13. Teenage Mutant Ninja Turtles v06 - City Fall, Part 1.zip	to_parse
2602	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/48. TMNT Universe 11 Main Stroy- The Jersy's Devil.zip	to_parse
2603	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/03. Teenage Mutant Ninja Turtles v02 - Enemies Old, Enemies New.zip	to_parse
2604	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/62. Teenage Mutant Ninja Turtles 78 - Invasion of the Triceratons part 2.zip	to_parse
2605	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/30. Teenage Mutant Ninja Turtles v14 - Order From Chaos.zip	to_parse
2606	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/21. Teenage Mutant Ninja Turtles v09 - Monsters, Misfits, and Madmen.zip	to_parse
2607	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/14. Deviations.zip	to_parse
2608	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/81. Teenage Mutant Ninja Turtles 89-92.zip	to_parse
2609	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/40. TMNT Universe 06-09 Back-up - What is Ninja.zip	to_parse
2610	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/55. Dimension X.zip	to_parse
2611	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/51. TMNT Universe 19-20 Main Story - Service Animals.zip	to_parse
2612	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/04. Raphael, Michelangelo, Donatello, Leonardo.zip	to_parse
2613	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/Teenage Mutant Ninja Turtles - Road To 100.zip	to_parse
2614	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/37. Teenage Mutant Ninja Turtles 65 - Christmas Special.zip	to_parse
2615	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/63. TMNT Universe 21 Back-up - How Woody Spent his Triceraton Invasion.zip	to_parse
2616	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/44. TMNT Universe 09-10 Main story- Toad Baron's Ball.zip	to_parse
2617	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/59. TMNT Universe 16-17 Back-up - Triceratots.zip	to_parse
2618	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/20. Annual 2014.zip	to_parse
2619	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/53. Free Comic Book Day 2017 - Trial of Krang Prologue.zip	to_parse
2620	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/29. Casey and April.zip	to_parse
2621	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/07. Splinter, Casey Jones.zip	to_parse
2622	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/73. Macro-Series 01 - Donatello.zip	to_parse
2623	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/54. Teenage Mutant Ninja Turtles 73 - Trial of Krang part 1.zip	to_parse
2624	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/80. Macro-Series 04 - Raphael.zip	to_parse
2625	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/02. Teenage Mutant Ninja Turtles - 30th Anniversary Special.cbz	to_parse
2626	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/34. Bepop & Rocksteady Destroy Everything 01-05.zip	to_parse
2627	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/10. April, Fugitoid.zip	to_parse
2628	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/36. TMNT Universe 01-05 Back-up - Inside Out.zip	to_parse
2629	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/08. Teenage Mutant Ninja Turtles v04 - Sins of the Fathers.zip	to_parse
2630	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/67. TMNT Universe 23 Back-up - Nobody Cares.zip	to_parse
2631	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/52. TMNT Universe 20 Back-up - Through Red Eyes.zip	to_parse
2632	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/60. Teenage Mutant Ninja Turtles 76-77 - Invasion of the Triceratons part 1.zip	to_parse
2633	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/16. Teenage Mutant Ninja Turtles v07 - City Fall, Part 2.zip	to_parse
2634	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/15. Villains Micro-Series v01.zip	to_parse
2635	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/24. Teenage Mutant Ninja Turtles - Ghostbusters.zip	to_parse
2636	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/06. Teenage Mutant Ninja Turtles v03 - Shadows of the Past.zip	to_parse
2637	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/05. Infestation 2 - TMNT.zip	to_parse
2638	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/39. TMNT Universe 06 Main Stroy - The Rot in the Shell.zip	to_parse
2729	Ongoing/Pearl/Pearl v01.zip	to_parse
2640	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/35. TNMT Universe 01-04 Main story - The War to Come.zip	to_parse
2641	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/75. Teenage Mutant Ninja Turtles 85.zip	to_parse
2642	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/72. TMNT Universe 24 Back-up - Life at Sea.zip	to_parse
2643	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/79. Macro-Series 03 - Leonardo.zip	to_parse
2644	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/65. TMNT Universe 21-22 Main Story - Lost Causes.zip	to_parse
2645	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/68. TMNT Universe 18 Back-up - Mutagen Maintenance.zip	to_parse
2646	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/01. Teenage Mutant Ninja Turtles v01 - Change is Constant.zip	to_parse
2647	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/49. TMNT Universe 12-15 Main story - Kara's Path.zip	to_parse
2649	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/64. Teenage Mutant Ninja Turtles 79-80 - Invasion of the Triceratons part 3.zip	to_parse
2650	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/74. Macro-Series 02 - Michelangelo.zip	to_parse
2651	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/71. TMNT Universe 23-24 Main Story - and Out Came the Reptiles.zip	to_parse
2652	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/76. TMNT Universe 25 - Spirit Walk.zip	to_parse
2653	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/22. Turtles in Time.zip	to_parse
2654	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/78. Teenage Mutant Ninja Turtles 86-88 - Battle Lines.zip	to_parse
2655	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/09. TNMT Annual 2012.zip	to_parse
2656	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/61. TMNT Universe 18 Main Story - Monster Hunt.zip	to_parse
2657	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/19. Utrom Empire.zip	to_parse
2658	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/42. TMNT Universe 07-08 Main story - Metalhead 2.0.zip	to_parse
2659	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/83. Shredder in Hell 01-05.zip	to_parse
2660	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/17. Villains Micro-Series v02.zip	to_parse
2661	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/46. Teenage Mutant Ninja Turtles 71-72 - Pantheon Family Reunion.zip	to_parse
2662	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/84. Teenage Mutant Ninja Turtles 97-100 - City at War Part II.zip	to_parse
2663	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/57. TMNT - Ghostbusters II.zip	to_parse
2664	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/23. Teenage Mutant Ninja Turtles v10 - New Mutant Order.zip	to_parse
2665	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/70. Teenage Mutant Ninja Turtles 81-84 - Kingdom of Rats.zip	to_parse
2666	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/50. TMNT Universe 12-15 Back-up - Prey.zip	to_parse
2667	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/18. Teenage Mutant Ninja Turtles v08 - Northampton.zip	to_parse
2668	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/27. Teenage Mutant Ninja Turtles v12 - Vengeance - Part 1.zip	to_parse
2669	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/69. TMNT Universe 19 Back-up - Kingdom of Rats Prelude.zip	to_parse
2670	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/25. Teenage Mutant Ninja Turtles v11 - Attack On Technodrome.zip	to_parse
2671	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/77. Bebop & Rocksteady Hit the Road.zip	to_parse
2672	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/11. Teenage Mutant Ninja Turtles v05 - Krang War.zip	to_parse
2673	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/43. Teenage Mutant Ninja Turtles 67-70 - Desperate Measures.zip	to_parse
2674	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/28. Teenage Mutant Ninja Turtles v13 - Vengeance - Part 2.zip	to_parse
2675	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/12. The Secret History of the Foot Clan.zip	to_parse
2676	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/47. TMNT - Usagi Yojimbo - Namazu.zip	to_parse
2677	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/41. Teenage Mutant Ninja Turtles 66 - Desperate Measures Prologue.zip	to_parse
2678	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/66. TMNT Universe 22 Back-up - Dangerous Waters.zip	to_parse
2679	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/58. TMNT Universe 16-17 Main story - From the Heart, From the Herd.zip	to_parse
2680	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/56. Teenage Mutant Ninja Turtles 74-75 - Trial of Krang part 2.zip	to_parse
2681	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/33. Teenage Mutant Ninja Turtles 61-64 - Chasing Phantoms.zip	to_parse
2682	Ongoing/Redneck/Redneck v02 - Eyes Upon You.zip	to_parse
2683	Ongoing/Redneck/Redneck v03 - Longhorns.zip	to_parse
2684	Ongoing/Redneck/Redneck v04 - Lone Star.zip	to_parse
2685	Ongoing/Redneck/Redneck v01 - Deep in the Heart.zip	to_parse
2686	Ongoing/East of West/02. East of West v02 - We Are All One.cbz	to_parse
2687	Ongoing/East of West/03. East of West v03 - There Is No Us.cbz	to_parse
2688	Ongoing/East of West/05. East of West v05 -  All These Secrets.zip	to_parse
2689	Ongoing/East of West/01. East of West v01 - The Promise.cbz	to_parse
2690	Ongoing/East of West/08. East of West v08.zip	to_parse
2691	Ongoing/East of West/09. East of West v09.zip	to_parse
2692	Ongoing/East of West/06. East of West v06.zip	to_parse
2693	Ongoing/East of West/04. East of West v04 - Who Wants War.zip	to_parse
2694	Ongoing/East of West/07. East of West v07.zip	to_parse
2696	Ongoing/Black Hammer/08. Black Hammer v04 - Age of Doom Part 2.zip	to_parse
2697	Ongoing/Black Hammer/10. Black Hammer '45.zip	to_parse
2698	Ongoing/Black Hammer/04. Sherlock Frankenstein and the Legion of Evil  01-04 + Black Hammer 12.zip	to_parse
2699	Ongoing/Black Hammer/05. Doctor Star & the Kingdom of Lost Tomorrows 01-04.zip	to_parse
2700	Ongoing/Black Hammer/07. The Quantum Age.zip	to_parse
2701	Ongoing/Black Hammer/03. Black Hammer v02 - The Event.zip	to_parse
2702	Ongoing/Black Hammer/06. Black Hammer - Age of Doom Part I.zip	to_parse
2703	Ongoing/Black Hammer/12. The World of Black Hammer Encyclopedia.zip	to_parse
2704	Ongoing/Black Hammer/01. Black Hammer v01 - Secret Origins.zip	to_parse
2006	Fini/Spread/02. Spread v02 - The Children's Crusade.zip	to_parse
2707	Ongoing/Injection/03. Injection 11-15.zip	to_parse
2708	Ongoing/Injection/02. Injection v02.zip	to_parse
2709	Ongoing/Injection/01. Injection v01.zip	to_parse
2711	Ongoing/Lazarus/09. The Lazarus Sourcebook v03 - Vassalovka.zip	to_parse
2712	Ongoing/Lazarus/10. Lazarus 27-28 - Fracture Prelude.zip	to_parse
2713	Ongoing/Lazarus/02. Lazarus v02 - Lift.zip	to_parse
2714	Ongoing/Lazarus/03. Lazarus v03 - Conclave.zip	to_parse
2715	Ongoing/Lazarus/04. The Lazarus Sourcebook v01 - Carlyle.zip	to_parse
2716	Ongoing/Lazarus/05. Lazarus v04 - Poison.zip	to_parse
2717	Ongoing/Lazarus/11. Lazarus v06 - Fracture 1.zip	to_parse
2718	Ongoing/Lazarus/08. Lazarus - X 66 01-06.zip	to_parse
2719	Ongoing/Lazarus/06. Lazarus v05 - Cull.zip	to_parse
2720	Ongoing/Lazarus/01. Lazarus v01.zip	to_parse
2721	Ongoing/Criminal/Criminal v05 - The Sinners.zip	to_parse
2722	Ongoing/Criminal/Criminal v00 - Teaser.zip	to_parse
2723	Ongoing/Criminal/Criminal v03 - The Dead and the Dying.zip	to_parse
2724	Ongoing/Criminal/Criminal v04 - Bad Night.zip	to_parse
2725	Ongoing/Criminal/Criminal v02 - Lawless.zip	to_parse
2726	Ongoing/Criminal/Criminal v06 - The Last of the Innocent.zip	to_parse
2727	Ongoing/Criminal/Criminal v07 - Wrong Time Wrong Place.zip	to_parse
2728	Ongoing/Criminal/Criminal v01 - Coward.zip	to_parse
2730	Ongoing/Pearl/Pearl v02 - 07-12.zip	to_parse
2731	Ongoing/Monstress/Monstress v02 - The Blood.zip	to_parse
2732	Ongoing/Monstress/Monstress v04 - The Chosen.zip	to_parse
2733	Ongoing/Monstress/Monstress v03 - Haven.zip	to_parse
2734	Ongoing/Monstress/Monstress v01 - Awakening.zip	to_parse
2736	Ongoing/Outcast/01. Outcast v01 - A Darkness Surrounds Him.zip	to_parse
2737	Ongoing/Outcast/06. Outcast 31-36.zip	to_parse
2738	Ongoing/Outcast/07. Outcast 37-42.zip	to_parse
2739	Ongoing/Outcast/02. Outcast v02 - A Vast and Unending Ruin.zip	to_parse
2740	Ongoing/Outcast/05. Outcast v05 - The New Path.zip	to_parse
2741	Ongoing/Outcast/04. Outcast v04 - Under Devil's Wing.zip	to_parse
2742	Ongoing/Kick-Ass/02. Hit Girl v1.zip	to_parse
2743	Ongoing/Kick-Ass/13. Hit-Girl v2 v06 - In India.zip	to_parse
2744	Ongoing/Kick-Ass/07. Kick-Ass v4 07-12.zip	to_parse
2745	Ongoing/Kick-Ass/04. Kick-Ass v3 01-08.zip	to_parse
2746	Ongoing/Kick-Ass/10. Hit-Girl v2 v04 - Hollywood.zip	to_parse
2747	Ongoing/Kick-Ass/05. Kick-Ass v4 01-06.zip	to_parse
2748	Ongoing/Kick-Ass/12. Hit-Girl v2 v05 - Hong Kong.zip	to_parse
2749	Ongoing/Kick-Ass/11.Kick-Ass v4 13-18.zip	to_parse
2750	Ongoing/Kick-Ass/06. Hit-Girl v2 v01 - Colombia.zip	to_parse
2751	Ongoing/Kick-Ass/09. Hit-Girl v2 v03 - Rome.zip	to_parse
2752	Ongoing/Kick-Ass/03. Kick-Ass v2 01-07.zip	to_parse
2753	Ongoing/Kick-Ass/01. Kick-Ass v1.zip	to_parse
2754	Ongoing/Kick-Ass/08. Hit-Girl v2 v02 - Canada.zip	to_parse
2755	Ongoing/Powers/Powers v04 - Supergroup.zip	to_parse
2756	Ongoing/Powers/Powers v17 - Vol 5 - 01-06.zip	to_parse
2757	Ongoing/Powers/Powers v07 - Forever.zip	to_parse
2758	Ongoing/Powers/Powers v08 - Legends.zip	to_parse
2759	Ongoing/Powers/Powers v12 - The 25.zip	to_parse
2761	Ongoing/Powers/Powers v06 - The Sellouts.zip	to_parse
2762	Ongoing/Powers/Powers v09 - Psychotic.zip	to_parse
2763	Ongoing/Powers/Powers v10 - Cosmic.zip	to_parse
2764	Ongoing/Powers/Powers v11 - Secret Identity.zip	to_parse
2765	Ongoing/Powers/Powers v15 - The Bureau Vol 01.zip	to_parse
2766	Ongoing/Powers/Powers v01 - Who Killed Retro Girl.zip	to_parse
2767	Ongoing/Powers/Powers v03 - Little Deaths.zip	to_parse
2768	Ongoing/Powers/Powers v13 - Z.zip	to_parse
2769	Ongoing/Powers/Powers v16 - The Bureau Vol 02.zip	to_parse
2770	Ongoing/Powers/Powers v05 - Anarchy.zip	to_parse
2771	Ongoing/Powers/Powers v14 - Gods.zip	to_parse
2772	Ongoing/Black Magick/01. Black Magick v01 - Awakening.zip	to_parse
2773	Ongoing/Black Magick/02. Black Magick 06-11.zip	to_parse
2774	Ongoing/Rat Queens/08. Rat Queens v2 11-15 - The Infernal Path.zip	to_parse
2775	Ongoing/Rat Queens/04. Rat Queens v2 01-05 - High Fantasies.zip	to_parse
2777	Ongoing/Rat Queens/01. Rat Queens v01-02 - Deluxe Hardcover.zip	to_parse
2778	Ongoing/Rat Queens/06. Rat Queens Special - Neon Static.zip	to_parse
2779	Ongoing/Rat Queens/02. Rat Queens v03 - Demons.zip	to_parse
2780	Ongoing/Rat Queens/03. Rat Queens - Webcomics.zip	to_parse
2781	Ongoing/Rat Queens/07. Rat Queens v2 06-10 - The Colossal Magic Nothing.zip	to_parse
2782	Ongoing/Rat Queens/05. Orc Dave.zip	to_parse
2783	Ongoing/Buffy the Vampire Slayer/Season 12/Buffy the Vampire Slayer Season 12 01-04 - The Reckoning.zip	to_parse
2784	Ongoing/Buffy the Vampire Slayer/Reboot/04. Chosen Ones.zip	to_parse
2785	Ongoing/Buffy the Vampire Slayer/Reboot/05. Buffy the Vampire Slayer 09-12.zip	to_parse
2786	Ongoing/Buffy the Vampire Slayer/Reboot/06. Hellmouth 01-05.zip	to_parse
2787	Ongoing/Buffy the Vampire Slayer/Reboot/01. Buffy the Vampire Slayer v01.zip	to_parse
2788	Ongoing/Buffy the Vampire Slayer/Reboot/03. Buffy the Vampire Slayer 05-08.zip	to_parse
2789	Ongoing/Buffy the Vampire Slayer/Reboot/02. Buffy the Vampire Slayer - Welcome to the Whedonverse.zip	to_parse
2790	Ongoing/Buffy the Vampire Slayer/Season 8/Buffy the Vampire Slayer Season 8 v02 - No Future for You.zip	to_parse
2791	Ongoing/Buffy the Vampire Slayer/Season 8/Buffy the Vampire Slayer Season 8 v05 - Predators and Prey.zip	to_parse
2792	Ongoing/Buffy the Vampire Slayer/Season 8/Buffy the Vampire Slayer Season 8 v04 - Time of Your Life.zip	to_parse
2793	Ongoing/Buffy the Vampire Slayer/Season 8/Buffy the Vampire Slayer Season 8 v07 - Twilight.zip	to_parse
1	Star Wars/Marvel/603. Age Of Resistance - Supreme Leader Snoke.zip	to_parse
20	Star Wars/Marvel/104. Age of The Republic - Jango Fett.zip	to_parse
41	Star Wars/Marvel/304. Darth Vader - Dark Lord of the Sith v02 - Legacy's End.zip	to_parse
71	Star Wars/Marvel/434. Doctor Aphra v06 - Unspeakable Rebel Superweapon.zip	to_parse
86	Star Wars/Marvel/610. Poe Dameron v01 - Black Squadron.zip	to_parse
92	Star Wars/Dark Horse (Brian Wood)/Star Wars by Brian Wood v01 - In The Shadow Of Yavin.zip	to_parse
133	Terry Moore/03. Rachel Rising/Rachel Rising 07-12.zip	to_parse
154	Valiant Comics/092. Wrath of the Eternal Warrior v03 - Deal With a Devil.zip	to_parse
163	Valiant Comics/026. Archer & Armstrong v04 - Sect Civil War.zip	to_parse
172	Valiant Comics/126. Bloodshot Salvation v02 - The Book of the Dead.zip	to_parse
199	Valiant Comics/030. Shadowman v04 - Fear, Blood, and Shadows.zip	to_parse
229	Valiant Comics/116. Harbinger Renegade v02 - Massacre.zip	to_parse
249	Valiant Comics/028. Bloodshot and H.A.R.D. Corps 22-23.zip	to_parse
259	Valiant Comics/070. Book of Death - Legends of the Geomancer (from issues).zip	to_parse
286	Valiant Comics/017. Quantum and Woody v01 - The World's Worst Superhero Team.zip	to_parse
309	comics à trier/comics/Locke & Key - Extras/Locke & Key - Free Comic Book Day Edition (2011) (Minutemen).cbz	to_parse
320	comics à trier/Marvel Zombies/Marvel Zombies vs. Army Of Darkness (01 - 05) (2007) (Minutemen-DarthScanner)/Marvel Zombies vs Army Of Darkness 04 (of 05) (2007) (Minutemen-DarthScanner).zip	to_parse
331	comics à trier/Marvel Zombies/Marvel Zombies Destroy (01 - 05) (2012) (digital) (Minutemen-PhD)/Marvel Zombies Destroy! 04 (of 05) (2012) (digital) (Minutemen-PhD).zip	to_parse
359	comics à trier/Marvel Zombies/Marvel Zombies Return (01 - 05) (2009) (Digital) (Cypher-Empire)/Marvel Zombies Return 02 (of 05) (2009) (Digital) (Cypher-Empire).zip	to_parse
381	DC/00. Elseworlds & autres histoires/The Dark Knight Returns v00 - The Last Crusade - The Deluxe Edition.zip	to_parse
417	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/11. Injustice - Gods Among Us v10 - Year 5 03.zip	to_parse
423	DC/00. Elseworlds & autres histoires/Injustice - Gods Among Us/12. Injustice - Ground Zero v01.zip	to_parse
447	DC/00. Elseworlds & autres histoires/The Dark Knight Returns v02 - The Dark Knight Strikes Again + Bonus.zip	to_parse
488	DC/00. Elseworlds & autres histoires/Peut-etre plus tard/Nevermore/Nevermore 03.zip	to_parse
490	DC/00. Elseworlds & autres histoires/Batman - The Shadow - The Murder Geniuses.zip	to_parse
2795	Ongoing/Buffy the Vampire Slayer/Season 8/Buffy the Vampire Slayer Season 8 v03 - Wolves at the Gate.zip	to_parse
2796	Ongoing/Buffy the Vampire Slayer/Season 8/Buffy the Vampire Slayer Season 8 v06 - Retreat.zip	to_parse
2797	Ongoing/Buffy the Vampire Slayer/Season 8/Buffy the Vampire Slayer Season 8 v01 - The Long Way Home.zip	to_parse
2798	Ongoing/Buffy the Vampire Slayer/Season 10/Buffy the Vampire Slayer Season 10 v05 - Pieces on the Ground.zip	to_parse
2799	Ongoing/Buffy the Vampire Slayer/Season 10/Buffy the Vampire Slayer Season 10 v01 - New Rules.zip	to_parse
2800	Ongoing/Buffy the Vampire Slayer/Season 10/Buffy the Vampire Slayer Season 10 v04 - Old Demons.zip	to_parse
2801	Ongoing/Buffy the Vampire Slayer/Season 10/Buffy the Vampire Slayer Season 10 v02 - I Wish.zip	to_parse
2802	Ongoing/Buffy the Vampire Slayer/Season 10/Buffy the Vampire Slayer Season 10 v06 - Own It.zip	to_parse
2803	Ongoing/Buffy the Vampire Slayer/Season 10/Buffy the Vampire Slayer Season 10 v03 - Love Dares You.zip	to_parse
2804	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 09.cbz	to_parse
2805	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 14.cbz	to_parse
2806	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 19.zip	to_parse
2807	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 04.cbz	to_parse
2808	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 11.cbz	to_parse
2809	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 25.zip	to_parse
2810	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 18.zip	to_parse
2811	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 10.cbz	to_parse
2812	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 15.cbz	to_parse
2813	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 13.cbz	to_parse
2814	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 17.zip	to_parse
2815	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 22.zip	to_parse
2816	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 01.cbz	to_parse
2818	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 06.cbz	to_parse
2819	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 12.cbz	to_parse
2820	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 23.cbz	to_parse
2821	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 16.cbz	to_parse
2822	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 02.cbz	to_parse
2823	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 05.cbz	to_parse
2824	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 24.zip	to_parse
2825	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 20.zip	to_parse
2826	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 07.cbz	to_parse
2827	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 03.cbz	to_parse
2828	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 21.cbz	to_parse
2829	Ongoing/Buffy the Vampire Slayer/Season 11/Buffy the Vampire Slayer Season 11 v02 - One Girl in All the World.zip	to_parse
2830	Ongoing/Buffy the Vampire Slayer/Season 11/Buffy the Vampire Slayer Season 11 v01 - The Spread of Their Evil.zip	to_parse
524	DC/03. Rebirth/A ordonner/Ocean Master - Year Of The Villain.zip	to_parse
549	DC/03. Rebirth/A ordonner/The Batman Who Laughs 01-07 + The Grim Knight (from issues).zip	to_parse
570	DC/03. Rebirth/136. Action Comics Special.zip	to_parse
573	DC/03. Rebirth/024. Hal Jordan and the Green Lantern Corps v01 - Sinestro's Law.zip	to_parse
610	DC/03. Rebirth/108. Superman v4 33-36 - Imperius Lex.zip	to_parse
634	DC/03. Rebirth/026. Gotham Academy v2 - Second Semester 01-03 - Welcome Back.zip	to_parse
660	DC/03. Rebirth/061. All-Star Batman v02 - Ends of the Earth.zip	to_parse
681	DC/03. Rebirth/178. Justice League Dark v2 05-07.zip	to_parse
697	DC/03. Rebirth/166. Wonder Woman and Justice League Dark - The Witching Hour.zip	to_parse
730	DC/03. Rebirth/191. Batman v3 & The Flash v5 64-65 - The Price (from issues).zip	to_parse
748	DC/02. New 52/223. Batman v2 51.zip	to_parse
757	DC/02. New 52/129. Detective Comics v2 v06 - Icarus.zip	to_parse
775	DC/02. New 52/080. Batman and Robin v2 v04 - Requiem for Damian.zip	to_parse
805	DC/02. New 52/114. Batman and Robin v2 v05 - The Big Burn.zip	to_parse
831	DC/02. New 52/164. Sinestro 09-12 + Annual 01.zip	to_parse
839	DC/02. New 52/217. Black Canary 10-12.zip	to_parse
847	DC/02. New 52/009. Justice League v2 v01 - Origin.zip	to_parse
868	DC/02. New 52/047. Green Lantern Corps v3 06-12 - Alpha War.zip	to_parse
893	DC/02. New 52/086. Green Lantern - New Guardians 25-27.zip	to_parse
918	DC/02. New 52/049. Green Lantern - New Guardians 11-12.zip	to_parse
930	DC/02. New 52/220. Detective Comics v2 51-52.zip	to_parse
944	DC/02. New 52/091. Green Lantern - New Guardians 28-30.zip	to_parse
969	DC/01. Crisis to crisis/011. Swamp Thing v02 - Love and Death.zip	to_parse
982	DC/01. Crisis to crisis/150. The Flash, The Fastest Man Alive 01-06 - Lightning in a bottle (One Year Later).zip	to_parse
1013	DC/01. Crisis to crisis/051. Batman - Troika.zip	to_parse
1018	DC/01. Crisis to crisis/210. Green Lantern Corps v2 27-32 - Sins of the Star Sapphires.zip	to_parse
1046	DC/01. Crisis to crisis/196. Justice League of America v2 27-34 - When Worlds Collide.zip	to_parse
1076	DC/01. Crisis to crisis/114. Adventures of Superman 633-638 + Secret Files and Origins - That Healing Touch.zip	to_parse
1086	DC/01. Crisis to crisis/221. Bruce Wayne - The Road Home.zip	to_parse
1102	DC/01. Crisis to crisis/155. Catwoman v3 53-58 - The Replacements (One Year Later).zip	to_parse
1127	DC/01. Crisis to crisis/161. Wonder Woman v3 02-04 + Annual 01 - Who is Wonder Woman (One Year Later).zip	to_parse
1161	DC/01. Crisis to crisis/120. Countdown to Inifinite Crisis + The O.M.A.C. Project 01-03.zip	to_parse
1172	DC/01. Crisis to crisis/028. Animal Man v02 - Origin of the Species.zip	to_parse
1184	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 20 - Day of Vengeance - Infinite Crisis Special.zip	to_parse
1219	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 47 - Green Arrow 52.zip	to_parse
1223	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 41 - Batman 648.zip	to_parse
1255	DC/01. Crisis to crisis/145 bis. Infinite Crisis - ultra complet/Infinite Crisis Complete 56 - Infinite Crisis 05 pages 01-12.zip	to_parse
1273	DC/01. Crisis to crisis/057. Kingdom Come.zip	to_parse
1282	DC/01. Crisis to crisis/181. Action Comics 858-864 - The Legion of Super Heroes.zip	to_parse
1323	Marvel/Lu/Deadpool/Deadpool Killogy/01. Deadpool Kills the Marvel Universe/Deadpool Kills the Marvel Universe 02.zip	to_parse
1348	Marvel/Lu/Runaways/Runaways v02 09.zip	to_parse
1361	Marvel/Lu/Runaways/Extras/Mystic Arcana - Sister Grimm.cbz	to_parse
1386	Marvel/Lu/Runaways/Runaways v02 18.zip	to_parse
1405	Marvel/Lu/Runaways/Runaways v02 06.zip	to_parse
1415	Marvel/Ultimate Universe/141. Ultimate Comics X-Men 19-22 - Reservation X.zip	to_parse
1440	Marvel/Ultimate Universe/048. Ultimate Fantastic Four 27-29 - President Thor.zip	to_parse
1445	Marvel/Ultimate Universe/110. Ultimate Spider-Man v2 01-06 - The World According to Peter Parker.zip	to_parse
1483	Marvel/Ultimate Universe/103. Ultimate X-Men - Fantastic Four Annual + Fantastic Four - X-Men Annual.zip	to_parse
1513	Marvel/Ultimate Universe/011. Ultimate X-Men 07-12 - Return to Weapon X.zip	to_parse
1534	Marvel/Ultimate Universe/143. Ultimate Comics X-Men 23-28 - Natural Resources.zip	to_parse
1566	Marvel/Ultimate Universe/044. Ultimate Fantastic Four 21-26 - Crossover.zip	to_parse
1599	Fini/Transmetropolitan v06 - Gouge Away.zip	to_parse
1616	Fini/Rasputin/01. Rasputin v01 - The Road to the Winter Palace.zip	to_parse
1644	Fini/The Sandman v04 - Season Of Mists.zip	to_parse
1662	Fini/Klaus v02 - Klaus and the Witch of WinterFull.zip	to_parse
1686	Fini/Invisible Republic/03. Invisible Republic 11-15.zip	to_parse
1689	Fini/The Invisibles - The Deluxe Edition Book 04.cbz	to_parse
1698	Fini/The Ghost Fleet/01. The Ghost Fleet v01 - Deadhead.zip	to_parse
1717	Fini/The Walking Dead/24. The Walking Dead v20 - All Out War Part 1.zip	to_parse
1743	Fini/The Walking Dead/06. The Walking Dead v06 - This Sorrowful Life.zip	to_parse
1776	Fini/The Maxx/07. The Maxx Maxximized v05.zip	to_parse
1778	Fini/The Maxx/06. The Maxx Maxximized v04.zip	to_parse
1801	Fini/Mage v06 - Book 03 - The Hero Denied.zip	to_parse
1818	Fini/Sons of the Devil/02. Sons of the Devil 06-10.zip	to_parse
1840	Fini/Promethea/01. Promethea - The 20th Anniversary Deluxe Edition Book 01.zip	to_parse
1864	Fini/Jupiter's Circle & Legacy/Jupiter's Legacy/Jupiter's Legacy v2 01-05.zip	to_parse
1875	Fini/Morning Glories v02 - All Will Be Free.zip	to_parse
1884	Fini/DMZ v04 - Friendly Fire.zip	to_parse
1895	Fini/Sons of Anarchy/09. Sons of Anarchy - Redwood Original 09-12.zip	to_parse
1920	Fini/The United States of Murder Inc/01. The United States of Murder Inc. v01 - Truth.zip	to_parse
1949	Fini/Elephantmen & Hip Flask/Elephantmen/13. Elephantmen 72 + 77-80 - The Least, The Lost & The Last.zip	to_parse
1962	Fini/Elephantmen & Hip Flask/Elephantmen/01. Elephantmen v00 - Armed Forces.zip	to_parse
1983	Fini/Peter Panzerfaust v03 - Cry of the Wolf.zip	to_parse
2013	Fini/Invincible Tie-Ins/Extras/Invincible Ultimate Collection Vol 01 EXTRA MATERIAL ONLY (2005) (Lusiphur-DCP).zip	to_parse
2042	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/04 The Astounding Wolf-Man 004.cbz	to_parse
2059	Fini/Invincible Tie-Ins/The Astounding Wolf-Man/05 The Astounding Wolf-Man 005.zip	to_parse
2099	Fini/The Sandman v06 - Fables and Reflections.zip	to_parse
2122	Fini/Brass Sun - The Wheel of Worlds.zip	to_parse
2132	Fini/Planetary/05. Planetary v04 - Spacetime Archaeology.zip	to_parse
2153	Hellboy & BPRD/235 - B.P.R.D. - Hell on Earth  - The Return of the Master 100.zip	to_parse
2187	Hellboy & BPRD/232 - Lobster Johnson - Caput Mortuum.zip	to_parse
2207	Hellboy & BPRD/188 - Sir Edward Grey, Witchfinder - Lost and Gone Forever 04.cbz	to_parse
2212	Hellboy & BPRD/150 - B.P.R.D. - King of Fear 04.cbz	to_parse
2230	Hellboy & BPRD/052 - B.P.R.D. - Plague of Frogs 03.cbz	to_parse
2243	Hellboy & BPRD/089 - Hellboy - The Yearning (mini-comic insert from the Hellboy - Blood And Iron DVD).zip	to_parse
2288	Hellboy & BPRD/169 - B.P.R.D. - Hell on Earth - New World 02.cbz	to_parse
2300	Hellboy & BPRD/084 - BPRD - Garden Of Souls 02.cbz	to_parse
2320	Hellboy & BPRD/229 - B.P.R.D. - Hell on Earth - Exorcism 1.zip	to_parse
2344	Hellboy & BPRD/158 - Sir Edward Grey, Witchfinder - In the Service of Angels 04.cbz	to_parse
2373	Hellboy & BPRD/186 - Sir Edward Grey, Witchfinder - Lost and Gone Forever 02.cbz	to_parse
2388	Hellboy & BPRD/196 - B.P.R.D. Hell on Earth - Monsters 1.cbz	to_parse
2400	Ongoing/Manifest Destiny/05. Manifest Destiny 25-30 - Mnemophobia & Chronophobia.zip	to_parse
2439	Ongoing/Low/Low v02 - Before the Dawn Burns Us.zip	to_parse
2444	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1987 - Tales of the TNMT vol 1/Tales of the Teenage Mutant Ninja Turtles v01.cbz	to_parse
2460	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  56.zip	to_parse
2471	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2004 - Tales of the TNMT vol 2/Tales of the TMNTv2  61.zip	to_parse
2516	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Plastron Cafe 04.cbz	to_parse
2518	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Mirage Minicomics - Melting Pot.zip	to_parse
2529	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/Extras/Raphael - Bad Moon Rising 03.zip	to_parse
2561	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/2001 - Vol 4/TMNT v4 14.zip	to_parse
2578	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/04. Teenage Mutant Ninja Turtles - The Ultimate B&W Collection v03.zip	to_parse
2582	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1984 - Vol 1/16. Teenage Mutant Ninja Turtles - The Ultimate B&W Collection v04.zip	to_parse
2639	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/32. Teenage Mutant Ninja Turtles 56-60 - Leatherhead & Fox Hunt.zip	to_parse
2648	Ongoing/Teenage Mutant Ninja Turtles/04. IDW/82. Teenage Mutant Ninja Turtles 93-96 - City at War Part I.zip	to_parse
2695	Ongoing/Black Hammer/11. Black Hammer - Justice League - Hammer of Justice! 01-05.zip	to_parse
2706	Ongoing/Black Hammer/09. Black Hammer - Cthu-Louise.zip	to_parse
2710	Ongoing/Lazarus/07. The Lazarus Sourcebook v02 - Hock.zip	to_parse
2735	Ongoing/Outcast/03. Outcast v03 - This Little Light.cbz	to_parse
2760	Ongoing/Powers/Powers v02 - Roleplay.zip	to_parse
2776	Ongoing/Rat Queens/09. Rat Queens v07 - The Once and Future King.zip	to_parse
2794	Ongoing/Buffy the Vampire Slayer/Season 8/Buffy the Vampire Slayer Season 8 v08 - Last Gleaming.zip	to_parse
2817	Ongoing/Buffy the Vampire Slayer/Season 9/Buffy the Vampire Slayer Season 9 - 08.cbz	to_parse
2588	Ongoing/Teenage Mutant Ninja Turtles/01. Mirage/1993 - Vol 2/Teenage Mutant Ninja Turtles - Classics v09/Teenage Mutant Ninja Turtles - Classics v09.zip	to_parse
\.


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.books (id, name) FROM stdin;
\.


--
-- Data for Name: books_additional_files; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.books_additional_files (id, bookd_id, file_path) FROM stdin;
\.


--
-- Data for Name: books_issues; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.books_issues (id, bookd_id, issue_id) FROM stdin;
\.


--
-- Data for Name: issues; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.issues (id, volume_id, number, dir) FROM stdin;
\.


--
-- Data for Name: reading_order_elements; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.reading_order_elements (id, issue_id, book_id, reading_order_id) FROM stdin;
\.


--
-- Data for Name: reading_orders; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.reading_orders (id, name) FROM stdin;
\.


--
-- Data for Name: volumes; Type: TABLE DATA; Schema: public; Owner: master
--

COPY public.volumes (id, name) FROM stdin;
\.


--
-- Name: archives_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.archives_id_seq', 2830, true);


--
-- Name: books_additional_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.books_additional_files_id_seq', 1, false);


--
-- Name: books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.books_id_seq', 1, false);


--
-- Name: books_issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.books_issues_id_seq', 1, false);


--
-- Name: issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.issues_id_seq', 1, false);


--
-- Name: reading_order_elements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.reading_order_elements_id_seq', 1, false);


--
-- Name: reading_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.reading_orders_id_seq', 1, false);


--
-- Name: volumes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: master
--

SELECT pg_catalog.setval('public.volumes_id_seq', 1, false);


--
-- Name: __diesel_schema_migrations __diesel_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.__diesel_schema_migrations
    ADD CONSTRAINT __diesel_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: archives archives_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.archives
    ADD CONSTRAINT archives_pkey PRIMARY KEY (id);


--
-- Name: books_additional_files books_additional_files_file_path_key; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.books_additional_files
    ADD CONSTRAINT books_additional_files_file_path_key UNIQUE (file_path);


--
-- Name: books_additional_files books_additional_files_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.books_additional_files
    ADD CONSTRAINT books_additional_files_pkey PRIMARY KEY (id);


--
-- Name: books_issues books_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.books_issues
    ADD CONSTRAINT books_issues_pkey PRIMARY KEY (id);


--
-- Name: books books_name_key; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_name_key UNIQUE (name);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: reading_order_elements reading_order_elements_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.reading_order_elements
    ADD CONSTRAINT reading_order_elements_pkey PRIMARY KEY (id);


--
-- Name: reading_orders reading_orders_name_key; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.reading_orders
    ADD CONSTRAINT reading_orders_name_key UNIQUE (name);


--
-- Name: reading_orders reading_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.reading_orders
    ADD CONSTRAINT reading_orders_pkey PRIMARY KEY (id);


--
-- Name: volumes volumes_name_key; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.volumes
    ADD CONSTRAINT volumes_name_key UNIQUE (name);


--
-- Name: volumes volumes_pkey; Type: CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.volumes
    ADD CONSTRAINT volumes_pkey PRIMARY KEY (id);


--
-- Name: books_additional_files books_additional_files_bookd_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.books_additional_files
    ADD CONSTRAINT books_additional_files_bookd_id_fkey FOREIGN KEY (bookd_id) REFERENCES public.books(id);


--
-- Name: books_issues books_issues_bookd_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.books_issues
    ADD CONSTRAINT books_issues_bookd_id_fkey FOREIGN KEY (bookd_id) REFERENCES public.books(id);


--
-- Name: books_issues books_issues_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.books_issues
    ADD CONSTRAINT books_issues_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES public.issues(id);


--
-- Name: issues issues_volume_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_volume_id_fkey FOREIGN KEY (volume_id) REFERENCES public.volumes(id);


--
-- Name: reading_order_elements reading_order_elements_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.reading_order_elements
    ADD CONSTRAINT reading_order_elements_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- Name: reading_order_elements reading_order_elements_issue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.reading_order_elements
    ADD CONSTRAINT reading_order_elements_issue_id_fkey FOREIGN KEY (issue_id) REFERENCES public.issues(id);


--
-- Name: reading_order_elements reading_order_elements_reading_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: master
--

ALTER TABLE ONLY public.reading_order_elements
    ADD CONSTRAINT reading_order_elements_reading_order_id_fkey FOREIGN KEY (reading_order_id) REFERENCES public.reading_orders(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: master
--

GRANT USAGE ON SCHEMA public TO rw;
GRANT USAGE ON SCHEMA public TO PUBLIC;


--
-- Name: TABLE __diesel_schema_migrations; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.__diesel_schema_migrations TO rw;


--
-- Name: TABLE archives; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.archives TO rw;


--
-- Name: SEQUENCE archives_id_seq; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,USAGE ON SEQUENCE public.archives_id_seq TO rw;


--
-- Name: TABLE books; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.books TO rw;


--
-- Name: TABLE books_additional_files; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.books_additional_files TO rw;


--
-- Name: SEQUENCE books_additional_files_id_seq; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,USAGE ON SEQUENCE public.books_additional_files_id_seq TO rw;


--
-- Name: SEQUENCE books_id_seq; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,USAGE ON SEQUENCE public.books_id_seq TO rw;


--
-- Name: TABLE books_issues; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.books_issues TO rw;


--
-- Name: SEQUENCE books_issues_id_seq; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,USAGE ON SEQUENCE public.books_issues_id_seq TO rw;


--
-- Name: TABLE issues; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.issues TO rw;


--
-- Name: SEQUENCE issues_id_seq; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,USAGE ON SEQUENCE public.issues_id_seq TO rw;


--
-- Name: TABLE reading_order_elements; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reading_order_elements TO rw;


--
-- Name: SEQUENCE reading_order_elements_id_seq; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,USAGE ON SEQUENCE public.reading_order_elements_id_seq TO rw;


--
-- Name: TABLE reading_orders; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reading_orders TO rw;


--
-- Name: SEQUENCE reading_orders_id_seq; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,USAGE ON SEQUENCE public.reading_orders_id_seq TO rw;


--
-- Name: TABLE volumes; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.volumes TO rw;


--
-- Name: SEQUENCE volumes_id_seq; Type: ACL; Schema: public; Owner: master
--

GRANT SELECT,USAGE ON SEQUENCE public.volumes_id_seq TO rw;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: master
--

ALTER DEFAULT PRIVILEGES FOR ROLE master IN SCHEMA public GRANT USAGE ON SEQUENCES  TO rw;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: master
--

ALTER DEFAULT PRIVILEGES FOR ROLE master IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO rw;


--
-- PostgreSQL database dump complete
--


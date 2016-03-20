--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.1
-- Dumped by pg_dump version 9.5.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: discounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE discounts (
    id integer NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    price integer NOT NULL,
    description character varying DEFAULT ''::character varying NOT NULL,
    delete_flag boolean DEFAULT false NOT NULL,
    expiry_at timestamp without time zone,
    plan_id integer
);


--
-- Name: discounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE discounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE discounts_id_seq OWNED BY discounts.id;


--
-- Name: plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE plans (
    id integer NOT NULL,
    name character varying NOT NULL,
    price integer NOT NULL,
    "default" boolean NOT NULL,
    description character varying DEFAULT ''::character varying NOT NULL,
    delete_flag boolean DEFAULT false NOT NULL
);


--
-- Name: plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE plans_id_seq OWNED BY plans.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE subscriptions (
    id integer NOT NULL,
    braintree_transaction_id character varying,
    created_at timestamp without time zone NOT NULL,
    plan_id integer,
    discount_id integer
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subscriptions_id_seq OWNED BY subscriptions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    first_name character varying,
    last_name character varying,
    country character varying,
    city character varying,
    date_of_birth date,
    gender integer DEFAULT 0,
    program_type integer DEFAULT 0,
    institution character varying,
    year_of_participation integer,
    country_of_participation character varying,
    student_company_name character varying,
    university_name character varying,
    university_major character varying,
    founded_company_name character varying,
    current_company_name character varying,
    current_job_position character varying,
    interests character varying,
    short_bio character varying,
    alumni_position character varying,
    member_since date,
    facebook_url character varying,
    skype_id character varying,
    twitter_url character varying,
    linkedin_url character varying,
    mobile_phone character varying,
    avatar character varying,
    provider character varying,
    uid character varying DEFAULT ''::character varying NOT NULL,
    tokens text,
    registered boolean,
    confirmed_email boolean,
    completed_profile boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_super_user boolean DEFAULT false,
    customer_id character varying DEFAULT ''::character varying,
    subscription_id integer,
    tsv tsvector
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY discounts ALTER COLUMN id SET DEFAULT nextval('discounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY plans ALTER COLUMN id SET DEFAULT nextval('plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discounts
    ADD CONSTRAINT discounts_pkey PRIMARY KEY (id);


--
-- Name: plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_discounts_on_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discounts_on_plan_id ON discounts USING btree (plan_id);


--
-- Name: index_subscriptions_on_discount_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_discount_id ON subscriptions USING btree (discount_id);


--
-- Name: index_subscriptions_on_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_plan_id ON subscriptions USING btree (plan_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tsv ON users USING gin (tsv);


--
-- Name: index_users_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uid ON users USING btree (uid);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tsv', 'pg_catalog.simple', 'first_name', 'last_name', 'country', 'city', 'institution', 'country_of_participation', 'student_company_name', 'university_name', 'current_company_name', 'current_job_position', 'alumni_position', 'short_bio');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20141214132501');

INSERT INTO schema_migrations (version) VALUES ('20150324131703');

INSERT INTO schema_migrations (version) VALUES ('20151209131046');

INSERT INTO schema_migrations (version) VALUES ('20151209193631');

INSERT INTO schema_migrations (version) VALUES ('20160319170659');


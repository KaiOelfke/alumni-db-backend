--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

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
-- Name: applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE applications (
    id integer NOT NULL,
    motivation text,
    cv_file character varying,
    event_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE applications_id_seq OWNED BY applications.id;


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
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events (
    id integer NOT NULL,
    etype integer NOT NULL,
    name character varying NOT NULL,
    slogan character varying DEFAULT ''::character varying,
    cover_photo character varying,
    logo_photo character varying,
    description text DEFAULT ''::text,
    location character varying DEFAULT ''::character varying,
    dates character varying DEFAULT ''::character varying,
    facebook_url character varying,
    published boolean DEFAULT false NOT NULL,
    agenda character varying DEFAULT ''::character varying,
    contact_email character varying DEFAULT ''::character varying,
    phone_number character varying DEFAULT ''::character varying,
    delete_flag boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: fee_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fee_codes (
    id integer NOT NULL,
    code character varying NOT NULL,
    user_id integer,
    fee_id integer,
    delete_flag boolean DEFAULT false,
    used_flag boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: fee_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fee_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fee_codes_id_seq OWNED BY fee_codes.id;


--
-- Name: fees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fees (
    id integer NOT NULL,
    name character varying NOT NULL,
    price integer NOT NULL,
    deadline date NOT NULL,
    public_fee boolean DEFAULT false NOT NULL,
    event_id integer,
    delete_flag boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: fees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fees_id_seq OWNED BY fees.id;


--
-- Name: participations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE participations (
    id integer NOT NULL,
    fee_id integer,
    user_id integer,
    event_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    braintree_transaction_id character varying,
    status integer DEFAULT 0,
    delete_flag boolean DEFAULT false,
    arrival timestamp without time zone,
    departure timestamp without time zone,
    diet integer,
    allergies text,
    extra_nights text,
    other text,
    motivation text,
    cv_file character varying
);


--
-- Name: participations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE participations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE participations_id_seq OWNED BY participations.id;


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
    cover character varying,
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

ALTER TABLE ONLY applications ALTER COLUMN id SET DEFAULT nextval('applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY discounts ALTER COLUMN id SET DEFAULT nextval('discounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fee_codes ALTER COLUMN id SET DEFAULT nextval('fee_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fees ALTER COLUMN id SET DEFAULT nextval('fees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations ALTER COLUMN id SET DEFAULT nextval('participations_id_seq'::regclass);


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
-- Name: applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discounts
    ADD CONSTRAINT discounts_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: fee_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fee_codes
    ADD CONSTRAINT fee_codes_pkey PRIMARY KEY (id);


--
-- Name: fees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fees
    ADD CONSTRAINT fees_pkey PRIMARY KEY (id);


--
-- Name: participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT participations_pkey PRIMARY KEY (id);


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
-- Name: index_applications_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_applications_on_event_id ON applications USING btree (event_id);


--
-- Name: index_applications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_applications_on_user_id ON applications USING btree (user_id);


--
-- Name: index_discounts_on_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discounts_on_plan_id ON discounts USING btree (plan_id);


--
-- Name: index_fee_codes_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_fee_codes_on_code ON fee_codes USING btree (code);


--
-- Name: index_fee_codes_on_fee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_codes_on_fee_id ON fee_codes USING btree (fee_id);


--
-- Name: index_fee_codes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_codes_on_user_id ON fee_codes USING btree (user_id);


--
-- Name: index_fees_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fees_on_event_id ON fees USING btree (event_id);


--
-- Name: index_participations_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participations_on_event_id ON participations USING btree (event_id);


--
-- Name: index_participations_on_fee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participations_on_fee_id ON participations USING btree (fee_id);


--
-- Name: index_participations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participations_on_user_id ON participations USING btree (user_id);


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
-- Name: fk_rails_321cba9d8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fee_codes
    ADD CONSTRAINT fk_rails_321cba9d8a FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_63d3df128b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT fk_rails_63d3df128b FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE RESTRICT;


--
-- Name: fk_rails_69a6ba0466; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT fk_rails_69a6ba0466 FOREIGN KEY (fee_id) REFERENCES fees(id) ON DELETE CASCADE;


--
-- Name: fk_rails_703c720730; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT fk_rails_703c720730 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_87bc3eacd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discounts
    ADD CONSTRAINT fk_rails_87bc3eacd6 FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE;


--
-- Name: fk_rails_9c81909ca2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fees
    ADD CONSTRAINT fk_rails_9c81909ca2 FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;


--
-- Name: fk_rails_a1780b6d6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_a1780b6d6c FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL;


--
-- Name: fk_rails_bae88c7ffa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT fk_rails_bae88c7ffa FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;


--
-- Name: fk_rails_c7bba2837d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT fk_rails_c7bba2837d FOREIGN KEY (discount_id) REFERENCES discounts(id) ON DELETE RESTRICT;


--
-- Name: fk_rails_decd766d36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fee_codes
    ADD CONSTRAINT fk_rails_decd766d36 FOREIGN KEY (fee_id) REFERENCES fees(id) ON DELETE CASCADE;


--
-- Name: fk_rails_e80f5ca3a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY participations
    ADD CONSTRAINT fk_rails_e80f5ca3a2 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_ea85530745; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT fk_rails_ea85530745 FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20141214132501');

INSERT INTO schema_migrations (version) VALUES ('20150324131703');

INSERT INTO schema_migrations (version) VALUES ('20151209131046');

INSERT INTO schema_migrations (version) VALUES ('20151209193631');

INSERT INTO schema_migrations (version) VALUES ('20160319170659');

INSERT INTO schema_migrations (version) VALUES ('20160321141649');

INSERT INTO schema_migrations (version) VALUES ('20160321143809');

INSERT INTO schema_migrations (version) VALUES ('20160327174220');

INSERT INTO schema_migrations (version) VALUES ('20160508031133');

INSERT INTO schema_migrations (version) VALUES ('20160813133731');


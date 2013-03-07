create table score (
    id serial not null primary key,
    name text not null,
    date timestamp without time zone not null,
    qual_score int not null,
    elim_score int not null,
    final_score int not null,
    check (qual_score >= 0 and elim_score >= 0 and final_score >= 0)
);


insert into score (name, date, qual_score, elim_score, final_score)
values
    ('Test Person', current_timestamp, 20, 30, 40),
    ('Test Person 2', current_timestamp, 20, 30, 40);

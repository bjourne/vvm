#!/bin/bash

HOST="http://localhost:5000"

http -v POST $HOST/api/user email=bjourne@gmail.com
http -v POST $HOST/api/user email=frodoe@gmail.com

http -v POST $HOST/api/score user_id=1 program_date=2013-03-05 qual_score=0 qual_questions=3 elim_score=0 elim_questions=5 final_score=23 final_questions=30
http -v POST $HOST/api/score user_id=1 program_date=2013-03-04 qual_score=0 qual_questions=3 elim_score=0 elim_questions=5 final_score=23 final_questions=30
http -v POST $HOST/api/score user_id=2 program_date=2013-03-04 qual_score=0 qual_questions=3 elim_score=0 elim_questions=5 final_score=23 final_questions=30
http -v POST $HOST/api/score user_id=5 program_date=2013-03-04 qual_score=0 qual_questions=3 elim_score=0 elim_questions=5 final_score=23 final_questions=30

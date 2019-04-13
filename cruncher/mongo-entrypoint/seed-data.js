db.createUser(
   {
     user: "cruncher_user",
     pwd: "cruncher_password",
     roles: [ {role: "readWrite", db: "resumeCruncher"}]
   }
);

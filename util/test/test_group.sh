source ~/installer/tomcat-installer/util/user-util.sh


user_exists tomcat && echo "tomcat user exists"
user_exists tomcat2 || echo "tomcat2 user does not exist"
! user_exists tomcat2 && echo "tomcat2 user does not exist"

group_exists tomcat && echo "tomcat group exists"
group_exists tomcat2 || echo "tomcat2 group does not exist"
! group_exists tomcat2 && echo "tomcat2 group does not exist"

declare -a talend_installer_members
group_members talend-installer talend_installer_members
echo "talend-installer members: ${talend_installer_members[@]}"

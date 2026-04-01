package com.campus.travel.mapper;

import com.campus.travel.entity.UserAccount;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Update;
import org.apache.ibatis.annotations.Options;

import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface UserAccountMapper {
    @Select("SELECT * FROM user_account WHERE username = #{username}")
    UserAccount findByUsername(String username);

    @Select("SELECT * FROM user_account")
    List<UserAccount> findAll();

    @Update("UPDATE user_account SET account_status = #{status} WHERE id = #{id}")
    int updateStatus(@Param("id") Long id, @Param("status") String status);

    @Update("UPDATE user_account SET password_hash = #{hash} WHERE id = #{id}")
    int updatePassword(@Param("id") Long id, @Param("hash") String hash);

    @Insert("INSERT INTO user_account (username, password_hash, real_name, phone, school_name, student_no, auth_status, account_status, credit_score) " +
            "VALUES (#{username}, #{passwordHash}, #{realName}, #{phone}, #{schoolName}, #{studentNo}, 'pending', 'active', 100)")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(UserAccount user);

    @Update("UPDATE user_account SET real_name = #{realName}, phone = #{phone}, student_no = #{studentNo} WHERE username = #{username}")
    int updateProfile(UserAccount user);
}
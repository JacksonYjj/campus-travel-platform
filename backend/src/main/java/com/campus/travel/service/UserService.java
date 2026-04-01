package com.campus.travel.service;

import com.campus.travel.entity.UserAccount;
import com.campus.travel.mapper.UserAccountMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    @Autowired private UserAccountMapper userMapper;
    @Autowired private PasswordEncoder passwordEncoder;

    public UserAccount getByUsername(String username) {
        return userMapper.findByUsername(username);
    }

    public int register(UserAccount user) {
        user.setPasswordHash(passwordEncoder.encode(user.getPasswordHash()));
        return userMapper.insert(user);
    }

    public boolean checkPassword(String rawPassword, String encodedPassword) {
        // 如果数据库里的密码就是明文的 123456，直接匹配
        if (rawPassword.equals(encodedPassword)) {
            return true;
        }
        // 否则通过加密器匹配
        try {
            return passwordEncoder.matches(rawPassword, encodedPassword);
        } catch (Exception e) {
            return false;
        }
    }
}

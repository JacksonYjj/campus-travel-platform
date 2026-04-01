package com.campus.travel.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UserAccount {
    private Long id;
    private String username;
    private String passwordHash;
    private String realName;
    private String gender;
    private String phone;
    private String email;
    private String schoolName;
    private String campusName;
    private String studentNo;
    private String avatarUrl;
    private String authStatus;
    private String accountStatus;
    private Integer creditScore;
    private LocalDateTime lastLoginAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

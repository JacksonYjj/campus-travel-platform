package com.campus.travel.controller;

import com.campus.travel.entity.UserAccount;
import com.campus.travel.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    @Autowired private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody UserAccount user) {
        int result = userService.register(user);
        Map<String, Object> map = new HashMap<>();
        map.put("success", result > 0);
        return ResponseEntity.ok(map);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        
        UserAccount user = userService.getByUsername(username);
        
        if (user != null && userService.checkPassword(password, user.getPasswordHash())) {
            Map<String, Object> map = new HashMap<>();
            map.put("token", "simulated_jwt_token_for_" + username);
            map.put("user", user);
            return ResponseEntity.ok(map);
        }
        return ResponseEntity.status(401).body(Map.of("message", "用户名或密码错误"));
    }
}

package com.campus.travel.controller;

import com.campus.travel.entity.CarpoolTrip;
import com.campus.travel.entity.GroupTrip;
import com.campus.travel.entity.UserAccount;
import com.campus.travel.mapper.CarpoolTripMapper;
import com.campus.travel.mapper.GroupTripMapper;
import com.campus.travel.mapper.OrderMapper;
import com.campus.travel.mapper.UserAccountMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;

import java.util.HashMap;
import java.util.Map;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/trips")
public class TripController {
    @Autowired private CarpoolTripMapper carpoolMapper;
    @Autowired private GroupTripMapper groupMapper;
    @Autowired private OrderMapper orderMapper;
    @Autowired private UserAccountMapper userAccountMapper;

    private Long getUserIdFromRequest(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer simulated_jwt_token_for_")) {
            String username = authHeader.substring("Bearer simulated_jwt_token_for_".length());
            UserAccount user = userAccountMapper.findByUsername(username);      
            return user != null ? user.getId() : null;
        }
        return null;
    }

    @GetMapping("/carpool/list")
    public List<CarpoolTrip> getCarpoolList() {
        return carpoolMapper.findAllOpenTrips();
    }

    @PostMapping("/carpool/publish")
    public ResponseEntity<?> publishCarpool(@RequestBody CarpoolTrip trip) {    
        trip.setTripNo("CP" + System.currentTimeMillis());
        if (trip.getDriverUserId() == null) trip.setDriverUserId(1L);
        if (trip.getVehicleId() == null) trip.setVehicleId(1L);
        int res = carpoolMapper.insert(trip);
        return ResponseEntity.ok(res > 0);
    }

    @PostMapping("/carpool/join")
    public ResponseEntity<?> joinCarpool(@RequestParam Long tripId, @RequestParam(defaultValue = "1") Integer count, HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        if (userId == null) {
            return ResponseEntity.status(401).body("请先登录");
        }

        int res = carpoolMapper.bookSeats(tripId, count);
        if (res > 0) {
            Map<String, Object> params = new HashMap<>();
            params.put("orderNo", "CP" + System.currentTimeMillis() + userId);  
            params.put("tripId", tripId);
            params.put("userId", userId);
            params.put("count", count);
            params.put("amount", 20.00); 
            orderMapper.createCarpoolOrder(params);
            return ResponseEntity.ok("success");
        } else {
            return ResponseEntity.status(400).body("余座不足或行程已满");  
        }
    }

    @GetMapping("/group/list")
    public List<GroupTrip> getGroupList() {
        return groupMapper.findAllRecruitingTrips();
    }

    @PostMapping("/group/create")
    public ResponseEntity<?> createGroup(@RequestBody GroupTrip trip) {
        trip.setGroupNo("GT" + System.currentTimeMillis());
        if (trip.getCreatorUserId() == null) trip.setCreatorUserId(1L);
        int res = 0; try { res = groupMapper.insert(trip); } catch (Exception e) { e.printStackTrace(); return ResponseEntity.status(500).body(e.getMessage()); }
        return ResponseEntity.ok(res > 0);
    }

    @PostMapping("/group/join")
    public ResponseEntity<?> joinGroup(@RequestParam Long tripId, @RequestParam(defaultValue = "1") Integer count, HttpServletRequest request) {
        Long userId = getUserIdFromRequest(request);
        if (userId == null) {
            return ResponseEntity.status(401).body("请先登录");
        }

        int res = groupMapper.incrementMemberCount(tripId, count);
        if (res > 0) {
            Map<String, Object> params = new HashMap<>();
            params.put("orderNo", "GT" + System.currentTimeMillis() + userId);  
            params.put("tripId", tripId);
            params.put("userId", userId);
            params.put("count", count);
            params.put("phone", "13800000000"); 
            params.put("amount", 50.00); 
            orderMapper.createGroupOrder(params);
            return ResponseEntity.ok("success");
        } else {
            return ResponseEntity.status(400).body("人数已满或拼团异常");  
        }
    }
}
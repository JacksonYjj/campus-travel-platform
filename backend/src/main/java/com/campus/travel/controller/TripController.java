package com.campus.travel.controller;

import com.campus.travel.entity.CarpoolTrip;
import com.campus.travel.entity.GroupTrip;
import com.campus.travel.mapper.CarpoolTripMapper;
import com.campus.travel.mapper.GroupTripMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/trips")
public class TripController {
    @Autowired private CarpoolTripMapper carpoolMapper;
    @Autowired private GroupTripMapper groupMapper;

    @GetMapping("/carpool/list")
    public List<CarpoolTrip> getCarpoolList() {
        return carpoolMapper.findAllOpenTrips();
    }

    @PostMapping("/carpool/publish")
    public ResponseEntity<?> publishCarpool(@RequestBody CarpoolTrip trip) {
        trip.setTripNo("CP" + System.currentTimeMillis());
        // For demonstration, use a fixed driver id if not in context
        if (trip.getDriverUserId() == null) trip.setDriverUserId(1L);
        if (trip.getVehicleId() == null) trip.setVehicleId(1L);
        int res = carpoolMapper.insert(trip);
        return ResponseEntity.ok(res > 0);
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
}

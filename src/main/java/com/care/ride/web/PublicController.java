package com.care.ride.web;

import com.care.ride.domain.*;
import com.care.ride.dto.BookingRequest;
import com.care.ride.repo.*;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins={"http://localhost:4200","http://127.0.0.1:4201"})
public class PublicController {
	private final ServiceTypeRepo sRepo;
	private final BookingRepo bRepo;

	public PublicController(ServiceTypeRepo sRepo, BookingRepo bRepo){
		this.sRepo = sRepo;
		this.bRepo = bRepo;
	}

	@GetMapping("/services")
	public List<ServiceType> services(){
		return sRepo.findAll();
	}

	@PostMapping("/bookings")
	public ResponseEntity<?> create(@RequestBody @Valid BookingRequest req){
		var maybeSt = sRepo.findById(req.serviceTypeId());
		if (maybeSt.isEmpty()){
			return ResponseEntity.badRequest().body(java.util.Map.of("error","serviceTypeId not found"));
		}
		var st = maybeSt.get();
		var b = new Booking();
		b.setFullName(req.fullName());
		b.setPhone(req.phone());
		b.setEmail(req.email());
		b.setPickupAddress(req.pickupAddress());
		b.setDropoffAddress(req.dropoffAddress());
		b.setPickupTime(req.pickupTime());
		b.setNotes(req.notes());
		b.setServiceType(st);
		var saved = bRepo.save(b);
		return ResponseEntity.created(URI.create("/api/bookings/"+saved.getId())).body(saved);
	}
}
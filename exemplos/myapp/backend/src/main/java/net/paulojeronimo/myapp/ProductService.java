package net.paulojeronimo.myapp;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import java.util.ArrayList;
import java.util.List;

@Path("products")
public class ProductService {
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public List<String> getProducts() {
		ArrayList<String> rtn = new ArrayList<String>();
		rtn.add("iphone");
		rtn.add("ipad");
		rtn.add("ipod");
		return rtn;
	}
}

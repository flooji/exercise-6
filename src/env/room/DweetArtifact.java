package room;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.ObsProperty;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {
    private static final String DWEET_URL = "https://dweet.io:443/dweet/for/";
    private final HttpClient client = HttpClient.newHttpClient();;

    public void init() {
        log("Initialize DweetArtifact");
        defineObsProperty("dweet","Initialization");
    }

    @OPERATION
    public void sendMessage(String agentName, String message) {
        ObsProperty prop = getObsProperty("dweet");

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(DWEET_URL + agentName))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString("{\"message\": \"" + message + "\"}"))
                .build();

        try {
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if(response.statusCode() != 200) {
                log("Error sending message: " + response.body());
            } else {
                log("Received response from dweet.io: " + response.body());
                prop.updateValue(response.body().toString());
            }
        } catch (IOException | InterruptedException e) {
            log("Error: " + e.getMessage());
        }
    }

}

Test code for the backend on Motoko:
// Votacle Motoko Code

actor Votacle {
    type Candidate = {
        id: Nat;
        name: Text;
        voteCount: Nat;
    };

    type Election = {
        id: Nat;
        candidates: [Candidate];
        isActive: Bool;
    };

    var elections: [Election] = [];
    var currentElectionId: Nat = 0;

    // Create a new election
    public func createElection(candidates: [Text]): Nat {
        let election: Election = {
            id = currentElectionId;
            candidates = Array.map(candidates, func (name: Text): Candidate {
                {
                    id = Array.size(elections) + 1; // Candidate ID
                    name = name;
                    voteCount = 0;
                }
            });
            isActive = true;
        };

        elections := Array.append(elections, [election]); // Store on blockchain
        currentElectionId := currentElectionId + 1;

        return election.id; // Return the new election ID
    }

    // Vote for a candidate in an election
    public func vote(electionId: Nat, candidateId: Nat): Result<Text, Text> {
        switch (Array.get(elections, electionId)) {
            case (null) {
                return Err("Election does not exist");
            };
            case (election) {
                if (!election.isActive) {
                    return Err("Election is not active");
                };
                switch (Array.get(election.candidates, candidateId - 1)) {
                    case (null) {
                        return Err("Candidate does not exist");
                    };
                    case (candidate) {
                        // Increment vote count
                        let updatedCandidate: Candidate = {
                            id = candidate.id;
                            name = candidate.name;
                            voteCount = candidate.voteCount + 1;
                        };

                        // Update the candidates list
                        let updatedCandidates: [Candidate] =
                            Array.replace(election.candidates, candidateId - 1, updatedCandidate);
                        
                        let updatedElection: Election = {
                            id = election.id;
                            candidates = updatedCandidates;
                            isActive = true;
                        };

                        elections := Array.replace(elections, electionId, updatedElection); // Store on blockchain
                        return Ok("Vote successfully cast");
                    };
                }
        }
    }

    // Retrieve all elections
    public func getAllElections(): [Election] {
        return elections;
    }

    // Retrieve a specific election by ID
    public func getElection(electionId: Nat): ?Election {
        return Array.get(elections, electionId);
    }

    // Retrieve results of a specific election
    public func getElectionResults(electionId: Nat): ?[Candidate] {
        switch (Array.get(elections, electionId)) {
            case (null) {
                return null;
            };
            case (election) {
                return election.candidates; // Return candidates and their vote counts
            };
        }
    }

    // End the election
    public func endElection(electionId: Nat): Result<Text, Text> {
        switch (Array.get(elections, electionId)) {
            case (null) {
                return Err("Election does not exist");
            };
            case (election) {
                let updatedElection: Election = {
                    id = election.id;
                    candidates = election.candidates;
                    isActive = false; // Set election as inactive
                };
                elections := Array.replace(elections, electionId, updatedElection); // Store on blockchain
                return Ok("Election ended successfully");
            };
        }
    }
}